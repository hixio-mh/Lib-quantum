namespace Microsoft.Quantum.MachineLearning {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Optimization;

    function _MisclassificationRate(probabilities : Double[], labels : Int[], bias : Double) : Double {
        let proposedLabels = InferredLabels(bias, probabilities);
        return IntAsDouble(NMisclassifications(proposedLabels, labels)) / IntAsDouble(Length(probabilities));
    }

    /// # Summary
    /// Returns a bias value that leads to near-minimum misclassification score.
    function _UpdatedBias(labeledProbabilities: (Double, Int)[], bias: Double, tolerance: Double) : Double {
        mutable min1 = 1.0;
        mutable max0 = 0.0;

        // Find the range of classification probabilities for each class.
        for ((probability, label) in labeledProbabilities) {
            if (label == 1) {
                if (min1 > probability) {
                    set min1 = probability;
                }
            } else {
                if (max0 < probability) {
                    set max0 = probability;
                }
            }
        }

        // Exit early if we can find a perfect classification.
        if (max0 <= min1) {
            return 0.5 * (1.0 - max0 - min1);
        }

        // If we can't find a perfect classification, minimize to find
        // the best feasible bias.
        let optimum = LocalUnivariateMinimum(
            _MisclassificationRate(Mapped(Fst<Double, Int>, labeledProbabilities), Mapped(Snd<Double, Int>, labeledProbabilities), _),
            (0.5 - max0, 0.5 - min1),
            tolerance
        );
        return optimum::Coordinate;
    }

    /// # Summary
    /// Given the structure of a sequential classifier, trains the classifier
    /// on a given labeled training set.
    ///
    /// # Input
    /// ## structure
    /// Structure of the sequential classifier to be trained.
    /// ## parameterSource
    /// A list of parameter vectors to use as starting points during training.
    /// ## samples
    /// A set of labeled training data that will be used to perform training.
    /// ## options
    /// Configuration to be used when training; see
    /// @"microsoft.quantum.machinelearning.trainingoptions" and
    /// @"microsoft.quantum.machinelearning.defaulttrainingoptions" for more
    /// details.
    /// ## trainingSchedule
    /// A sampling schedule to use when selecting samples from the training
    /// data during training steps.
    /// ## validationSchedule
    /// A sampling schedule to use when selecting samples from the training
    /// data when selecting which start point resulted in the best classifier
    /// score.
    ///
    /// # Output
    /// A parameterization of the given classifier and a bias between the two
    /// classes, together corresponding to the best result from each of the
    /// given start points.
    ///
    /// # See Also
    /// - Microsoft.Quantum.MachineLearning.TrainSequentialClassifierAtModel
    /// - Microsoft.Quantum.MachineLearning.ValidateSequentialClassifier
    operation TrainSequentialClassifier(
        structure : SequentialClassifierStructure,
        parameterSource : Double[][],
        samples : LabeledSample[],
        options : TrainingOptions,
        trainingSchedule : SamplingSchedule,
        validationSchedule : SamplingSchedule
    ) : SequentialModel {
        mutable bestSoFar = SequentialModel([-1E12], -2.0);
        mutable bestValidation = Length(samples) + 1;

        let features = Mapped(_Features, samples);
        let labels = Mapped(_Label, samples);

        for ((idxStart, parameters) in Enumerated(parameterSource)) {
            Message($"Beginning training at start point #{idxStart}...");
            let proposedUpdate = TrainSequentialClassifierAtModel(
                structure, SequentialModel(parameters, 0.0),
                samples, options, trainingSchedule, 1
            );
            let probabilities = EstimateClassificationProbabilities(
                options::Tolerance,
                proposedUpdate::Parameters,
                structure,
                Sampled(validationSchedule, features),
                options::NMeasurements
            );
            // Find the best bias for the new classification parameters.
            let localBias = _UpdatedBias(
                Zip(probabilities, Sampled(validationSchedule, labels)),
                0.0,
                options::Tolerance
            );
            let localPL = InferredLabels(localBias, probabilities);
            let localMisses = NMisclassifications(localPL, Sampled(validationSchedule, labels));
            if (bestValidation > localMisses) {
                set bestValidation = localMisses;
                set bestSoFar = proposedUpdate;
            }

        }
        return bestSoFar;
    }

    /// # Summary
    /// attempts a single parameter update in the direction of mini batch gradient
    ///
    /// # Input
    /// ## miniBatch
    /// container of labeled samples in the mini batch
    ///
    /// ## param
    /// circuit parameters
    ///
    /// ## gates
    /// sequence of gates in the circuits
    ///
    /// ## lrate
    /// the learning rate
    ///
    /// ## measCount
    /// number of true quantum measurements to estimate probabilities.
    ///
    /// # Output
    /// (utility, (new)parameters) pair
    ///
    operation _RunSingleTrainingStep(
        miniBatch : LabeledSample[],
        options : TrainingOptions,
        param : Double[], gates : SequentialClassifierStructure
    )
    : (Double, Double[]) {
        mutable batchGradient = ConstantArray(Length(param), 0.0);
        let nQubits = MaxI(FeatureRegisterSize(miniBatch[0]::Features), NQubitsRequired(gates));
        let effectiveTolerance = options::Tolerance / IntAsDouble(Length(gates!));

        for (sample in miniBatch) {
            mutable err = IntAsDouble(sample::Label);
            if (err < 1.0) {
                set err = -1.0; //class 0 misclassified to class 1; strive to reduce the probability
            }
            let stateGenerator = StateGenerator(
                nQubits,
                ApproximateInputEncoder(effectiveTolerance, sample::Features)
            );
            let grad = EstimateGradient(
                gates, param, stateGenerator,
                options::NMeasurements
            );
            for (ip in 0..(Length(param) - 1)) {
                // GradientClassicalSample actually computes antigradient, but err*grad corrects it back to gradient
                set batchGradient w/= ip <- (batchGradient[ip] + options::LearningRate * err * grad[ip]);
            }

        }
        let updatedParameters = Mapped(PlusD, Zip(param, batchGradient));
        // TODO:REVIEW: Ok to interpret utility as size of the overall move?
        return (SquaredNorm(batchGradient), updatedParameters);

    }

    /// # Summary
    /// Perform one epoch of sequential classifier training on a subset of
    /// data samples.
    ///
    /// # Input
    /// ## samples
    /// The samples to be trained on.
    /// ## sched
    /// A sampling schedule defining a subset of samples to be included in training.
    /// ## schedScore
    /// A sampling schedule defining a subset of samples to be used in
    /// accuracy scoring.
    /// ## periodScore
    /// The number of gradient steps to be taken between scoring points.
    /// For best accuracy, set to 1.
    /// ## options
    /// Options to be used in training.
    /// ## structure
    /// The structure of the sequential classifier to be trained.
    /// ## model
    /// The parameterization and bias of the sequential model to be trained.
    /// ## nPreviousBestMisses
    /// The best number of misclassifications observed in previous epochs.
    ///
    /// # Output
    /// - The smallest number of misclassifications observed through to this
    ///   epoch.
    /// - The new best sequential model found.
    operation _RunSingleTrainingEpoch(
        samples : LabeledSample[],
        schedule : SamplingSchedule, periodScore: Int,
        options : TrainingOptions,
        structure : SequentialClassifierStructure,
        model : SequentialModel,
        nPreviousBestMisses : Int
    )
    : (Int, SequentialModel) {
        mutable nBestMisses = nPreviousBestMisses;
        mutable bestSoFar = model;
        let features = Mapped(_Features, samples);
        let actualLabels = Mapped(_Label, samples);

        let inferredLabels = InferredLabels(
            model::Bias,
            EstimateClassificationProbabilities(
                options::Tolerance, model::Parameters, structure,
                features, options::NMeasurements
            )
        );

        //An epoch is just an attempt to update the parameters by learning from misses based on LKG parameters
        let minibatches = Mapped(
            Subarray(_, samples),
            Chunks(
                options::MinibatchSize,
                Misclassifications(inferredLabels, actualLabels)
            )
        );
        for (minibatch in minibatches) {
            let (utility, updatedParameters) = _RunSingleTrainingStep(
                minibatch, options, bestSoFar::Parameters, structure
            );
            if (utility > 0.0000001) {
                // There has been some good parameter update.
                // Check if it actually improves things, and if so,
                // commit it.
                let probabilities = EstimateClassificationProbabilities(
                    options::Tolerance, updatedParameters, structure,
                    features, options::NMeasurements
                );
                let updatedBias = _UpdatedBias(
                    Zip(probabilities, actualLabels), model::Bias, options::Tolerance
                );
                let updatedLabels = InferredLabels(
                    updatedBias, probabilities
                );
                let nMisses = Length(Misclassifications(
                    updatedLabels, actualLabels
                ));
                if (nMisses < nBestMisses) {
                    set nBestMisses = nMisses;
                    set bestSoFar = SequentialModel(updatedParameters, updatedBias);
                }

            }

        }
        return (nBestMisses, bestSoFar);
    }

    /// # Summary
    /// Randomly rescales an input to either grow or shrink by a given factor.
    operation _RandomlyRescale(scale : Double, value : Double) : Double {
        return value * (
            1.0 + scale * (Random([0.5, 0.5]) > 0 ? 1.0 | -1.0)
        );
    }



    /// # Summary
    /// Given the structure of a sequential classifier, trains the classifier
    /// on a given labeled training set, starting from a particular model.
    ///
    /// # Input
    /// ## structure
    /// Structure of the sequential classifier to be trained.
    /// ## model
    /// The sequential model to be used as a starting point for training.
    /// ## samples
    /// A set of labeled training data that will be used to perform training.
    /// ## options
    /// Configuration to be used when training; see
    /// @"microsoft.quantum.machinelearning.trainingoptions" and
    /// @"microsoft.quantum.machinelearning.defaulttrainingoptions" for more
    /// details.
    /// ## schedule
    /// A sampling schedule to use when selecting samples from the training
    /// data during training steps.
    ///
    /// # Output
    /// A parameterization of the given classifier and a bias between the two
    /// classes, together corresponding to the best result from each of the
    /// given start points.
    ///
    /// # See Also
    /// - Microsoft.Quantum.MachineLearning.TrainSequentialClassifier
    /// - Microsoft.Quantum.MachineLearning.ValidateSequentialClassifier
    operation TrainSequentialClassifierAtModel(
        gates : SequentialClassifierStructure,
        model : SequentialModel,
        samples : LabeledSample[],
        options : TrainingOptions,
        schedule : SamplingSchedule,
        periodScore : Int
    )
    : SequentialModel {
        let nSamples = Length(samples);
        let features = Mapped(_Features, samples);
        let actualLabels = Mapped(_Label, samples);
        let probabilities = EstimateClassificationProbabilities(
            options::Tolerance, model::Parameters, gates,
            features, options::NMeasurements
        );
        mutable bestSoFar = model
            w/ Bias <- _UpdatedBias(
                Zip(probabilities, actualLabels),
                model::Bias, options::Tolerance
            );
        let inferredLabels = InferredLabels(
            bestSoFar::Bias, probabilities
        );
        mutable nBestMisses = Length(
            Misclassifications(inferredLabels, actualLabels)
        );
        mutable current = bestSoFar;

        //reintroducing learning rate heuristics
        mutable lrate = options::LearningRate;
        mutable batchSize = options::MinibatchSize;

        // Keep track of how many times a bias update has stalled out.
        mutable nStalls = 0;

        for (ep in 1..options::MaxEpochs) {
            let (nMisses, proposedUpdate) = _RunSingleTrainingEpoch(
                samples, schedule, periodScore,
                options
                    w/ LearningRate <- lrate
                    w/ MinibatchSize <- batchSize,
                gates, current,
                nBestMisses
            );
            if (nMisses < nBestMisses) {
                set nBestMisses = nMisses;
                set bestSoFar = proposedUpdate;
                if (IntAsDouble(nMisses) / IntAsDouble(nSamples) < options::Tolerance) { //Terminate based on tolerance
                    return bestSoFar;
                }
                set nStalls = 0; //Reset the counter of consequtive noops
                set lrate = options::LearningRate;
                set batchSize = options::MinibatchSize;
            }

            if (
                    NearlyEqualD(current::Bias, proposedUpdate::Bias) and _AllNearlyEqualD(current::Parameters, proposedUpdate::Parameters)
            ) {
                set nStalls += 1;
                // If we're more than halfway through our maximum allowed number of stalls,
                // exit early with the best we actually found.
                if (nStalls > options::MaxStalls) {
                    return bestSoFar; //Too many non-steps. Continuation makes no sense
                }

                // Otherwise, heat up the learning rate and batch size.
                set batchSize = nStalls; //batchSize + 1; //Try to fuzz things up with smaller batch count
                //and heat up  a bit
                set lrate *= 1.25;

                // If we stalled out, we'll also randomly rescale our parameters
                // and bias before updating.
                if (nStalls > options::MaxStalls / 2) {
                    set current = SequentialModel(
                        ForEach(_RandomlyRescale(options::StochasticRescaleFactor, _), proposedUpdate::Parameters),
                        _RandomlyRescale(options::StochasticRescaleFactor, proposedUpdate::Bias)
                    );
                }
            } else {
                // If we learned successfully this iteration, reset the number of
                // stalls so far.
                set nStalls = 0; //Reset the counter of consequtive noops
                set lrate = options::LearningRate;
                set batchSize = options::MinibatchSize;

                // Since we didn't stall out, we can set the parameters and bias
                // as normal, without randomizing.
                set current = proposedUpdate;
            }
        }

        return bestSoFar;
    }

}
