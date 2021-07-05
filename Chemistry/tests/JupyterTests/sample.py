import logging
logging.basicConfig(level=logging.INFO)

import json

import qsharp
from qsharp.serialization import map_tuples

qsharp.packages.add("microsoft.quantum.chemistry")

# For now, it is better if you compile the entry-point operation from Python (instead of using a .qs file):
TrotterEstimateEnergy = qsharp.compile("""
    open Microsoft.Quantum.Chemistry.JordanWigner;
    
    operation TrotterEstimateEnergy (qSharpData: JordanWignerEncodingData, nBitsPrecision : Int, trotterStepSize : Double) : (Double, Double) {
        
        let (nSpinOrbitals, data, statePrepData, energyShift) = qSharpData!;
        
        // Order of integrator
        let trotterOrder = 1;
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(qSharpData, trotterStepSize, trotterOrder);
        
        // Prepare ProductState
        let statePrep =  PrepareTrialState(statePrepData, _);
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        let estEnergy = estPhase * rescaleFactor + energyShift;
        return (estPhase, estEnergy);
    }
""")

qsharp.packages.add("microsoft.quantum.chemistry.jupyter")

filename = "broombridge_v0.2.yaml"

## Load fermion Hamiltonian from Broombridge file.
args = { 'fileName': filename }
fh = qsharp.client._execute(f'%chemistry.fh.load {json.dumps(args)}', raise_on_stderr=True)
print("fh", fh)
print("------------\n")


## Here I show how to add a couple of completely made-up terms to the Hamiltonian:
args = { 'hamiltonian': fh, 'fermionTerms': [ ([4,6], 1.0), ([0,2,2,0], 1.0)] }
fh = qsharp.client._execute(f'%chemistry.fh.add_terms {json.dumps(map_tuples(args))}', raise_on_stderr=True)
print("fh:\n", fh)
print("------------\n")


## Get the "UCCSD |G>" wavefunction defined in broombridge:
args = { 'fileName': filename, 'inputstate': "UCCSD |G>" }
inputstate = qsharp.client._execute(f'%chemistry.inputstate.load {json.dumps(map_tuples(args))}', raise_on_stderr=True)
print("inputstate:\n", inputstate)
print("------------\n")


## Jordan-Wigner encode so it can be simulated in Q#:
args = { 'hamiltonian': fh, 'inputState': inputstate }
qsharp_encoding = qsharp.client._execute(f'%chemistry.encode {json.dumps(map_tuples(args))}', raise_on_stderr=True)
print("qsharp_encoding complete.")
print("------------\n")

print('Starting simulation.')
result = TrotterEstimateEnergy.simulate(qSharpData=qsharp_encoding, nBitsPrecision=10, trotterStepSize=.4)
print(f'Trotter simulation. (phase, energy): {result}')
