// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon
{
    
    open Microsoft.Quantum.Primitive;
    
    
    /// # Summary
    /// Given operations implementing operators `U` and `V`, performs the
    /// operation `U†VU` on a target. That is, this operation
    /// conjugates `V` with `U`.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.WithC
    /// - Microsoft.Quantum.Canon.WithA
    /// - Microsoft.Quantum.Canon.WithCA
    operation With<'T> (outerOperation : ('T => Unit : Adjoint), innerOperation : ('T => Unit), target : 'T) : Unit
    {
        outerOperation(target);
        innerOperation(target);
        Adjoint outerOperation(target);
    }
    
    
    /// # Summary
    /// Given operations implementing operators `U` and `V`, performs the
    /// operation `U†VU` on a target. That is, this operation
    /// conjugates `V` with `U`.
    /// The modifier `A` indicates that the inner operation is adjointable.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.With
    operation WithA<'T> (outerOperation : ('T => Unit : Adjoint), innerOperation : ('T => Unit : Adjoint), target : 'T) : Unit
    {
        body (...)
        {
            outerOperation(target);
            innerOperation(target);
            Adjoint outerOperation(target);
        }
        
        adjoint invert;
    }
    
    
    /// # Summary
    /// Given operations implementing operators `U` and `V`, performs the
    /// operation `U†VU` on a target. That is, this operation
    /// conjugates `V` with `U`.
    /// The modifier `C` dictates that the inner operation is controllable.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.With
    operation WithC<'T> (outerOperation : ('T => Unit : Adjoint), innerOperation : ('T => Unit : Controlled), target : 'T) : Unit
    {
        body (...)
        {
            outerOperation(target);
            innerOperation(target);
            Adjoint outerOperation(target);
        }
        
        controlled (controlRegister, ...)
        {
            outerOperation(target);
            Controlled innerOperation(controlRegister, target);
            Adjoint outerOperation(target);
        }
    }
    
    
    /// # Summary
    /// Given operations implementing operators `U` and `V`, performs the
    /// operation `U†VU` on a target. That is, this operation
    /// conjugates `V` with `U`.
    /// The modifier `CA` indicates that the inner operation is controllable
    /// and adjointable.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$. Note that the
    /// outer operation $U$ needs to be adjointable, but does not
    /// need to be controllable.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    /// ## target
    /// The input to be provided to the outer and inner operations.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The target on which each of the inner and outer operations act.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Canon.With
    operation WithCA<'T> (outerOperation : ('T => Unit : Adjoint), innerOperation : ('T => Unit : Adjoint, Controlled), target : 'T) : Unit
    {
        body (...)
        {
            outerOperation(target);
            innerOperation(target);
            Adjoint outerOperation(target);
        }
        
        adjoint invert;
        
        controlled (controlRegister, ...)
        {
            outerOperation(target);
            Controlled innerOperation(controlRegister, target);
            Adjoint outerOperation(target);
        }
        
        controlled adjoint invert;
    }
    
}


