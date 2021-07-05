﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Xunit;
using Microsoft.Quantum.Chemistry;
using Microsoft.Quantum.Simulation.Core;

using System.Text.RegularExpressions;
using System;
using System.Linq;
using System.Collections.Generic;

namespace Microsoft.Quantum.Chemistry.Tests
{

    public class TTermValueTests
    {
        [Fact]
        void NormTest()
        {
            var norm = new double[] { 1.0, 2.0, 4.0, 0.1 }.Norm(1.0);
            Assert.Equal(7.1, norm);

            norm = new double[] { 1.0, 2.0, 4.0, 0.1 }.Norm(100.0);
            Assert.Equal(4.0, norm,5);
        }

        [Fact]
        void DoubleAddTest()
        {
            var x = new DoubleCoeff(1.0);
            var y = new DoubleCoeff(2.0);
            Assert.Equal(3.0, (x + y));
        }

        [Fact]
        void DoubleReferenceTest()
        {
            var x = new DoubleCoeff(1.0);
            var y = new DoubleCoeff(3.0);
            var z = x + y;
            Assert.Equal(1.0, x.Value);
            Assert.Equal(3.0, y.Value);
            Assert.Equal(4.0, z);
        }

        [Fact]
        void DoubleSubtractTest()
        {
            var x = new DoubleCoeff(1.0);
            var y = new DoubleCoeff(3.0);
            var z = x - y;
            Assert.Equal(1.0, x.Value);
            Assert.Equal(3.0, y.Value);
            Assert.Equal(-2.0, z);
        }
    }
}