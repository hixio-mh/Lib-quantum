﻿// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the
// Microsoft Software License Terms for Microsoft Quantum Simulation Library (Preview).
// See LICENSE.md in the project root for license information.


using Microsoft.Quantum.Simulation.Core;

using System;
using System.Linq;
using System.Collections.Generic;

using System.Runtime.Serialization.Formatters.Binary;
using System.IO;
using System.IO.Compression;
using YamlDotNet.Serialization;
using Microsoft.Extensions.Logging;

namespace Microsoft.Quantum.Chemistry
{
    using static FermionTermType.Common;

    /// <summary>
    /// Representation of a general Fermion Hamiltonian. This Hamiltonian is
    /// assumed to be a linear combination of sequences of creation
    /// and annihilation operators. 
    /// </summary>
    public partial class FermionHamiltonian
    {
        /// <summary>
        /// List of Hamiltonian input states.
        /// </summary>
        public List<InputState> InputStates = new List<InputState>();
        
        /// <summary>
        /// Data structure representing an input state.
        /// </summary>
        public struct InputState
        {
            public string Label;
            public Double Energy;
            public ((Double, Double) complexCoeff, FermionTerm term)[] Superposition;
        }

        #region Function for state preparation
        /// <summary>
        /// This approximates the Hamiltonian ground state by a greedy algorithm 
        /// that minimizes only the PP term energies. If there are no PP terms,
        /// states will be occupied in lexicographic order.
        /// </summary>
        /// <returns>
        /// Greedy trial state for minimizing Hamiltonian diagonal one-electron energy.
        /// </returns>
        public InputState GreedyStatePreparation()
        {
            var label = "Greedy";
            (Double, Double) coeff = (1.0, 0.0);
            var conjugate = Enumerable.Range(0, (int)NElectrons).Select(o => (Int64)1).ToArray();

            if (FermionTerms.ContainsKey(PPTermType))
            {
                var hPPTermSortedByCoeff = FermionTerms[PPTermType];
                var spinOrbitals = hPPTermSortedByCoeff.OrderBy(o => o.coeff).Select(o => o.SpinOrbitalIndices.First()).Take((int)NElectrons).ToArray();
                var fermionTerm = new FermionTerm(conjugate, spinOrbitals, 1.0);
                fermionTerm.ToSpinOrbitalCanonicalOrder();
                fermionTerm.coeff = 1.0;

                var superposition = new((Double, Double), FermionTerm)[] {
                            (coeff, fermionTerm)
                            };
                return new InputState { Label = label, Superposition = superposition };
            }
            else
            {
                var fermionTerm = new FermionTerm(
                    (int)NElectrons,
                    conjugate,
                    Enumerable.Range(0, (int)NElectrons).Select(o => (Int64)o).ToArray(),
                    1.0);
                var superposition = new((Double, Double), FermionTerm)[] {
                            (coeff, fermionTerm)
                            };
                return new InputState { Label = label, Superposition = superposition };
            }
        }
        
        #endregion

    }

}