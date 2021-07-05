#!/bin/env python
# -*- coding: utf-8 -*-
##
# iqsharp.py: Client for the IQ# Jupyter kernel.
##
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##


import subprocess
import time
import http.client
import atexit
import json
import sys
import urllib.parse
import os
import jupyter_client

from io import StringIO
from collections import defaultdict
from typing import List, Dict, Callable, Any
from pathlib import Path
from qsharp.utils import log_messages
from qsharp.serialization import map_tuples, unmap_tuples

## LOGGING ##

import logging
logger = logging.getLogger(__name__)

## CLASSES ##

class IQSharpError(RuntimeError):
    def __init__(self, iqsharp_errors : List[str]):
        self.iqsharp_errors = iqsharp_errors
        error_msg = StringIO()
        error_msg.write("The Q# kernel raised the following errors:\n")
        error_msg.writelines([
            "    " + msg for msg in iqsharp_errors
        ])
        super().__init__(error_msg.getvalue())

class IQSharpClient(object):
    kernel_manager = None
    kernel_client = None
    def __init__(self):
        logger.info("Starting IQ# kernel...")
        self.kernel_manager = jupyter_client.KernelManager(kernel_name='iqsharp')

    ## Server Lifecycle ##

    def start(self):
        self.kernel_manager.start_kernel()
        self.kernel_client = self.kernel_manager.client()
        atexit.register(self.stop)

    def stop(self):
        try:
            self.kernel_manager.shutdown_kernel()
        except:
            pass

    def is_ready(self):
        try:
            result = self.execute('%history', timeout=30)
        except Exception as ex:
            logger.debug('Exception while checking if IQ# is ready.', exc_info=ex)
            return
        return True

    ## Public Interface ##

    def compile(self, body):
        return self.execute(body)

    def get_available_operations(self) -> List[str]:
        return self.execute('%who', raise_on_stderr=False)

    def get_operation_metadata(self, name : str) -> Dict[str, Any]:
        return self.execute(f"?{name}")

    def get_workspace_operations(self) -> List[str]:
        return self.execute("%workspace")

    def reload(self) -> None:
        return self.execute(f"%workspace reload", raise_on_stderr=True)

    def add_package(self, name : str) -> None:
        return self.execute(f"%package {name}", raise_on_stderr=True)

    def get_packages(self) -> List[str]:
        return self.execute("%package", raise_on_stderr=False1)

    def simulate(self, op, **params) -> Any:
        return self.execute(f'%simulate {op._name} {json.dumps(map_tuples(params))}')

    def estimate(self, op, **params) -> Dict[str, int]:
        raw_counts = self.execute(f'%estimate {op._name} {json.dumps(map_tuples(params))}')
        # Convert counts to ints, since they get turned to floats by JSON serialization.
        return {
            operation_name: int(count)
            for operation_name, count in raw_counts.items()
        }

    def execute(self, input, return_full_result=False, raise_on_stderr=False, **kwargs):
        results = []
        errors = []
        def output_hook(msg):
            if msg['msg_type'] == 'execute_result':
                results.append(msg)
            else:
                if raise_on_stderr and msg['msg_type'] == 'stream' and msg['content']['name'] == 'stderr':
                    errors.append(msg['content']['text'])
                else:
                    self.kernel_client._output_hook_default(msg)
        reply = self.kernel_client.execute_interactive(input, output_hook=output_hook, **kwargs)
        # There should be either zero or one execute_result messages.
        if errors:
            raise IQSharpError(errors)
        if results:
            assert len(results) == 1
            content = results[0]['content']
            if 'application/json' in content['data']:
                obj = unmap_tuples(json.loads(content['data']['application/json']))
            else:
                obj = None
            return (obj, content) if return_full_result else obj
        else:
            return None
