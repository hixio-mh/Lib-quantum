﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections.Generic;

using Microsoft.Quantum.Chemistry;
using Microsoft.Quantum.Chemistry.LadderOperators;

namespace Microsoft.Quantum.Chemistry.OrbitalIntegrals
{
    using static Microsoft.Quantum.Chemistry.Extensions;
    
    /// <summary>
    /// LadderType representing orbital overlap integrals.
    /// </summary>
    public class OrbitalIntegral : ITermIndex<TermType.OrbitalIntegral, OrbitalIntegral>
    {
        public enum Convention
        {
            Dirac, Mulliken
        }

        /// <summary>
        /// Indices of orbitals in the overlap integral.
        /// </summary>
        public int[] OrbitalIndices = new int[] { };

        /// <summary>
        /// Coefficient of the orbital overlap integral.
        /// </summary>
        public double Coefficient;

        /// <summary>
        /// Parameterless constructors. Sets this as an empty OrbitalIntegral with coefficient 0.0
        /// </summary>
        public OrbitalIntegral() : this(0.0)
        {
        }

        public OrbitalIntegral(double coefficient)
        {
            OrbitalIndices = new int[] { };
            Coefficient = coefficient;
        }

        /// <summary>
        /// Constructor for orbital integral object.
        /// </summary>
        /// <param name="orbitalIndices">Array of orbital indices in Dirac notation.</param>
        /// <param name="coefficient">coefficient of orbital integral.</param>
        public OrbitalIntegral(IEnumerable<int> orbitalIndices, double coefficient = 0.0) 
        {
            OrbitalIndices = orbitalIndices.ToArray();
            Coefficient = coefficient;
        }

        /// <summary>
        /// Constructor for orbital integral object.
        /// </summary>
        /// <param name="orbitalIndices">Array of orbital indices.</param>
        /// <param name="coefficient">coefficient of orbital integral.</param>
        /// <param name="convention">Convention for ordering of orbital indices.</param>
        public OrbitalIntegral(IEnumerable<int> orbitalIndices, double coefficient, Convention convention = Convention.Mulliken)
        {
            if (convention == Convention.Mulliken)
            {
                if (orbitalIndices.Count() == 2)
                {
                    OrbitalIndices = orbitalIndices.Select(o => o).ToArray();
                }
                else if (orbitalIndices.Count() == 4)
                {
                    var p = orbitalIndices.ElementAt(0);
                    var q = orbitalIndices.ElementAt(2);
                    var r = orbitalIndices.ElementAt(3);
                    var s = orbitalIndices.ElementAt(1);
                    OrbitalIndices = new int[] { p, q, r, s };
                }
                else
                {
                    throw new System.ArgumentException("Mulliken convention for not 2 or 4 indices is not defined.");
                }
                Coefficient = coefficient;
            }
            else
            {
                OrbitalIndices = orbitalIndices.ToArray();
                Coefficient = coefficient;
            }
        }

        public TermType.OrbitalIntegral TermType
        {
            get
            {
                switch (Length)
                {
                    case 0:
                        return Chemistry.TermType.OrbitalIntegral.Identity;
                    case 2:
                        return Chemistry.TermType.OrbitalIntegral.OneBody;
                    case 4:
                        return Chemistry.TermType.OrbitalIntegral.TwoBody;
                    default:
                        throw new ArgumentException("Attempted to classify unimplemented orbital integral.");
                }
            }
        }
        /// <summary>
        /// Returns the sign of this term.
        /// </summary>
        /// <returns>Sign of this term.</returns>
        public int Sign => 1;

        /// <summary>
        /// Sets the sign of this fermion term to one.
        /// </summary>
        public void ResetSign()
        {
            Coefficient = 1.0;
        }

        /// <summary>
        /// Returns length of indices in orbital integral.
        /// </summary>
        /// <returns>Length of orbital indices.</returns>
        public int Length => OrbitalIndices.Length;


        /// <summary>
        /// Enumerates over all orbital integrals with the same coefficient
        /// as this.
        /// These symmetries arise from: 
        /// - Indistinguishability of electrons.
        /// - Orbitals are assumed to be real.
        /// </summary>
        /// <returns>Array of orbital integrals with the same coefficient.</returns>
        public OrbitalIntegral[] EnumerateOrbitalSymmetries()
        {
            var coefficient = Coefficient;
            if (OrbitalIndices.Length == 2)
            {
                var i = OrbitalIndices[0];
                var j = OrbitalIndices[1];
                var symmetries = new int[][]
                {
                    new int[] {i, j},
                    new int[] {j, i}
                };
                return symmetries.Distinct(new ArrayEqualityComparer<int>()).Select(o => new OrbitalIntegral(o, coefficient)).ToArray();
            }
            else if (OrbitalIndices.Length == 4)
            {
                var i = OrbitalIndices[0];
                var j = OrbitalIndices[1];
                var k = OrbitalIndices[2];
                var l = OrbitalIndices[3];
                var symmetries = new int[][] {
                    new int[] { i, j, k, l }, // 0123
                    new int[] { j, i, l, k }, // 1032
                    new int[] { k, l, i, j }, // 2301
                    new int[] { l, k, j, i }, // 3210
                    new int[] { i, k, j, l }, // 0213
                    new int[] { k, i, l, j }, // 2031
                    new int[] { j, l, i, k }, // 1302
                    new int[] { l, j, k, i }  // 3120
                };
                return symmetries.Distinct(new ArrayEqualityComparer<int>()).Select(o => new OrbitalIntegral(o, coefficient)).ToArray();
            }
            else
            {
                throw new System.NotImplementedException();
            }
        }

        /// <summary>
        /// Creates a copy of this instance.
        /// </summary>
        public OrbitalIntegral Clone()
        {
            var newArray = OrbitalIndices.Clone<int>();
            return new OrbitalIntegral(newArray, Coefficient);
        }

        /// <summary>
        /// Returns orbital indices sorted in a canonical form that generates
        /// the same set of orbital integrals through <see cref="EnumerateSpinOrbitals"/>.
        /// </summary>
        /// <returns>An <see cref="OrbitalIntegral"/> in canonical form.</returns>
        public OrbitalIntegral ToCanonicalForm()
        {
            var symmetries = EnumerateOrbitalSymmetries().Select(o => o.OrbitalIndices).ToList();
            symmetries.Sort(new ArrayLexicographicComparer<int>());
            return new OrbitalIntegral(symmetries.First(), Coefficient);
        }

        /// <summary>
        /// Checks of this orbital integral has indices sorted in canonical order.
        /// </summary>
        /// <returns>Returns <see cref="bool"/> if the orbital integral indices are canonically sorted
        /// and <see cref="false"/> otherwise.
        /// </returns>
        public bool IsInCanonicalOrder()
        {
            if (Length == 2 || Length == 4)
            {
                var canonicalOrder = ToCanonicalForm();
                return canonicalOrder.OrbitalIndices.SequenceEqual(OrbitalIndices);
            }
            else
            {
                throw new System.NotImplementedException();
            }
        }

        /// <summary>
        /// Override for string representation of orbital integral data.
        /// </summary>
        /// <returns>String representation of orbital integral data.</returns>
        public override string ToString()
        {
            return $"([{String.Join(",", OrbitalIndices)}], {Coefficient})";
        }

        /// <summary>
        /// Enumerates over all spin-orbital integrals represented 
        /// by this term.
        /// These symmetries arise from: 
        /// - Indistinguishability of electrons.
        /// - Orbitals are assumed to be real.
        /// - electron spins must be paired.
        /// </summary>
        /// <returns>
        /// Array of spin-orbital orbital integrals with the same coefficient.
        /// </returns>
        public SpinOrbital[][] EnumerateSpinOrbitals()
        {
            // Assumes spinOrbitals has an even number of elements
            // Only index over like spins S1 S2 S3 ... S3 S2 S1
            const int nSpins = 2;
            var nSpinOrbitalArrays = nSpins.Pow(OrbitalIndices.Length / 2);
            SpinOrbital[][] spinOrbitalArrayOfArray = new SpinOrbital[OrbitalIndices.Length][];
            for (int idx = 0; idx < nSpinOrbitalArrays; idx++)
            {
                SpinOrbital[] spinOrbitalArray = new SpinOrbital[OrbitalIndices.Length];
                for (int idxOrbital = 0; idxOrbital < OrbitalIndices.Length / 2; idxOrbital++)
                {
                    var fst = idxOrbital;
                    var lst = OrbitalIndices.Length - idxOrbital - 1;
                    var spin = (Spin)((idx / nSpins.Pow(idxOrbital)) % nSpins);
                    spinOrbitalArray[fst] = new SpinOrbital(OrbitalIndices[fst], spin);
                    spinOrbitalArray[lst] = new SpinOrbital(OrbitalIndices[lst], spin);
                }
                spinOrbitalArrayOfArray[idx] = spinOrbitalArray;
            }
            return spinOrbitalArrayOfArray;
        }


        #region Equality Testing

        public override bool Equals(object obj) => (obj is OrbitalIntegral x) ? Equals(x) : false;

        public bool Equals(OrbitalIntegral x)
        {
            // If parameter is null, return false.
            if (ReferenceEquals(x, null))
            {
                return false;
            }

            // Optimization for a common success case.
            if (ReferenceEquals(this, x))
            {
                return true;
            }

            // If run-time types are not exactly the same, return false.
            if (GetType() != x.GetType())
            {
                return false;
            }
            // Return true if the fields match.
            return OrbitalIndices.SequenceEqual(x.OrbitalIndices);
        }

        public override int GetHashCode()
        {
            int h = 19;
            foreach (var i in OrbitalIndices)
            {
                h = h * 53 + i;
            }
            return h;
        }

        public static bool operator ==(OrbitalIntegral x, OrbitalIntegral y)
        {
            // Check for null on left side.
            if (Object.ReferenceEquals(x, null))
            {
                if (Object.ReferenceEquals(y, null))
                {
                    // null == null = true.
                    return true;
                }

                // Only the left side is null.
                return false;
            }
            // Equals handles case of null on right side.
            return x.Equals(y);
        }

        public static bool operator !=(OrbitalIntegral x, OrbitalIntegral y) => !(x == y);
        #endregion

    }
}

