// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Diagnostics.CodeAnalysis;
using Microsoft.Quantum.Diagnostics.Emulation;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;

namespace Microsoft.Quantum.Diagnostics
{

    public partial class AllowAtMostNCallsCA<__TInput__, __TOutput__>
    {
        public class Native : AllowAtMostNCallsCA<__TInput__, __TOutput__>
        {
            private SimulatorBase? Simulator;
            
            private static Dictionary<(Type, Type), Stack<IDisposable>> Handlers =
                new Dictionary<(Type, Type), Stack<IDisposable>>();

            private static readonly (Type, Type) Key = (typeof(__TInput__), typeof(__TOutput__));

            public Native(IOperationFactory m) : base(m)
            {
                Simulator = m as SimulatorBase;
            }

            public override Func<(long, ICallable, string), QVoid> __Body__ => _args =>
            {
                if (Simulator == null) return QVoid.Instance;

                var (nTimes, op, message) = _args;
                var callStack = ImmutableStack<string>.Empty;
                var callSites = ImmutableList<ImmutableStack<string>>.Empty;

                if (!Handlers.ContainsKey(Key))
                {
                    Handlers[Key] = new Stack<IDisposable>();
                }

                bool IsSelf(ICallable callable) =>
                    callable.FullName == "Microsoft.Quantum.Diagnostics.AllowAtMostNCallsCA";

                // Record whether or not the condition checked by this allow
                // has failed, so that we can property unwind in the endOperation
                // handler below.
                var failed = false;

                Handlers[Key].Push(Simulator.RegisterOperationHandlers(
                    startOperation: (callable, data) =>
                    {
                        if (IsSelf(callable)) return;
                        callStack = callStack.Push(callable.FullName);
                        if (callable.FullName == op.FullName)
                        {
                            callSites = callSites.Add(callStack);
                            if (callSites.Count > nTimes)
                            {
                                Simulator?.MaybeDisplayDiagnostic(new CallSites
                                {
                                    Sites = callSites,
                                    Subject = op.FullName
                                });
                                failed = true;
                                throw new ExecutionFailException(
                                    $"Operation {op.FullName} was called more than the allowed {nTimes} times:\n{message}"
                                );
                            }
                        }
                    },

                    endOperation: (callable, data) =>
                    {
                        // Ignore call stack entries that happen after we've
                        // failed, or that are generated by ending the
                        // condition itself.
                        if (failed || IsSelf(callable)) return;
                        try
                        {
                            callStack = callStack.Pop();
                        }
                        catch (InvalidOperationException ex)
                        {
                            System.Console.WriteLine($"Call stack was empty when popped:\n{ex}");
                        }
                    }
                ));
                return QVoid.Instance;
            };

            public override Func<(long, ICallable, string), QVoid> __AdjointBody__ => _args =>
            {
                if (Simulator == null) return QVoid.Instance;

                Handlers[Key].Pop().Dispose();

                return QVoid.Instance;
            };
        }

    }

}
