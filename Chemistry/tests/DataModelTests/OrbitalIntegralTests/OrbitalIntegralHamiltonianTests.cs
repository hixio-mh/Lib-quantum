﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Diagnostics;

using Microsoft.Quantum.Chemistry.Broombridge;
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;

using Newtonsoft.Json;

using Xunit;

namespace Microsoft.Quantum.Chemistry.Tests
{

    public class OrbitalIntegralHamiltonianTests
    {
        // These orbital integrals represent terms in molecular Hydrogen
        private static IEnumerable<OrbitalIntegral> orbitalIntegrals = new OrbitalIntegral[]
            {
                    new OrbitalIntegral(new[] { 0,0 }, -1.252477495),
                    new OrbitalIntegral(new[] { 1,1 }, -0.475934275),
                    new OrbitalIntegral(new[] { 0,0,0,0 }, 0.674493166),
                    new OrbitalIntegral(new[] { 0,1,0,1 }, 0.181287518),
                    new OrbitalIntegral(new[] { 0,1,1,0 }, 0.663472101),
                    new OrbitalIntegral(new[] { 1,1,1,1 }, 0.697398010)
            };

        [Fact]
        void BuildHamiltonian()
        {
            var hamiltonian = new OrbitalIntegralHamiltonian();
            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
        }

        [Fact]
        void CheckTermPresent()
        {
            var hamiltonian = new OrbitalIntegralHamiltonian();
            var addTerms0 = orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())).ToList();
            hamiltonian.AddRange(addTerms0);

            // Check that all terms present.
            foreach(var term in addTerms0)
            {
                Assert.Equal(term.Item2, hamiltonian.GetTerm(term.o));
            }

            // Now check that indexing is by value and not by reference.
            var newTerms0Copy = new[] {
                new[] { 0,0 },
                new[] { 1,1 },
                new[] { 0,0,0,0 },
                new[] { 0,1,0,1 },
                new[] { 0,1,1,0 },
                new[] { 1,1,1,1 } }.Select(o => new OrbitalIntegral(o, 0.123));
            foreach (var term in addTerms0.Zip(newTerms0Copy, (a,b) => (a.Item2.Value, b)))
            {
                Assert.Equal(term.Item1, hamiltonian.GetTerm(term.b).Value);
            }


            var orb = new OrbitalIntegral(new[] { 0,1,1,0}, 4.0);
            Assert.Equal(new[] { 0, 1, 1, 0 }, orb.OrbitalIndices);
            Assert.Equal(addTerms0[4].o.OrbitalIndices, orb.OrbitalIndices);

            Debug.WriteLine($"Term type is { orb.TermType.ToString()}");
            Debug.WriteLine($"Coefficient is { hamiltonian.Terms[orb.TermType][new OrbitalIntegral(orb.OrbitalIndices, orb.Coefficient)]}");
            Debug.WriteLine($"Coefficient is { hamiltonian.Terms[orb.TermType][addTerms0[4].o]}");

            Assert.True(0.663472101 == hamiltonian.Terms[orb.TermType][new OrbitalIntegral(orb.OrbitalIndices, orb.Coefficient)]);
        }

        [Fact]
        void CountTerms()
        {
            var hamiltonian = new OrbitalIntegralHamiltonian();
            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            var oneNorm = hamiltonian.Norm();
            Assert.Equal(orbitalIntegrals.Count(), hamiltonian.CountTerms());

            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            Assert.Equal(orbitalIntegrals.Count(), hamiltonian.CountTerms());

            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            Assert.Equal(orbitalIntegrals.Count(), hamiltonian.CountTerms());

            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            Assert.Equal(orbitalIntegrals.Count(), hamiltonian.CountTerms());
        }

        [Fact]
        void NormTerms()
        {
            var hamiltonian = new OrbitalIntegralHamiltonian();
            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            var oneNorm = hamiltonian.Norm();

            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            Assert.Equal(oneNorm * 2.0, hamiltonian.Norm());

            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            Assert.Equal(oneNorm * 3.0, hamiltonian.Norm());

            hamiltonian.AddRange(orbitalIntegrals.Select(o => (o, o.Coefficient.ToDoubleCoeff())));
            Assert.Equal(oneNorm * 4.0, hamiltonian.Norm());
        }

        [Fact]
        public void JsonEncoding()
        {
            var filename = "Broombridge/broombridge_v0.2.yaml";
            Data broombridge = Deserializers.DeserializeBroombridge(filename);
            var problemData = broombridge.ProblemDescriptions.First();

            OrbitalIntegralHamiltonian original = problemData.OrbitalIntegralHamiltonian;

            var json = JsonConvert.SerializeObject(original);
            File.WriteAllText("oribital.original.json", json);

            var serialized = JsonConvert.DeserializeObject<OrbitalIntegralHamiltonian>(json);
            File.WriteAllText("orbital.serialized.json", JsonConvert.SerializeObject(serialized));

            Assert.Equal(original.SystemIndices.Count, serialized.SystemIndices.Count);
            Assert.Equal(original.Terms.Count, serialized.Terms.Count);
            Assert.Equal(original.Norm(), serialized.Norm());
            Assert.Equal(original.ToString(), serialized.ToString());
        }
    }
}