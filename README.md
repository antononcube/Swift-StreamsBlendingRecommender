# Swift Streams Blending Recommender

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Swift implementation of a Streams Blending Recommender (SBR) framework.

Generally speaking, SBR is a "computer scientist" implementation of a recommendation system
based on sparse linear algebra. See the article
["Mapping Sparse Matrix Recommender to Streams Blending Recommender"](https://github.com/antononcube/MathematicaForPrediction/tree/master/Documentation/MappingSMRtoSBR),
[AA1], for detailed theoretical description of the data structures and operations with them.

This implementation is closely following the Raku Object-Oriented Programming (OOP) implementation
["ML::StreamsBlendingRecommender"](https://github.com/antononcube/Raku-ML-StreamsBlendingRecommender), [AAp1].

Related implementations are:

- Software monad
["MonadicSparseMatrixRecommender"](https://github.com/antononcube/MathematicaForPrediction/blob/master/MonadicProgramming/MonadicSparseMatrixRecommender.m), [AAp2],
in Mathematica

- Software monad ["SMRMon-R"](https://github.com/antononcube/R-packages/tree/master/SMRMon-R), [AAp3], in R

- Object-Oriented Programming (OOP) implementation
["SparseMatrixRecommender"](https://pypi.org/project/SparseMatrixRecommender/), [AAp4], in Python


Instead of "monads" the implementations in this package and [AAp1, AAp4] use OOP classes. 


--------

## Usage examples

*TBD...*


--------

## Implementation

### UML diagram

The [PlantUML spec](https://plantuml.com/class-diagram) and diagram
can be obtained with the CLI script `swiftplantuml` of the package "SwiftPlantUML", [MEp1]:

```shell
swiftplantuml classdiagram .
```


--------


## References

### Articles

[AA1] Anton Antonov, 
["Mapping Sparse Matrix Recommender to Streams Blending Recommender"](https://github.com/antononcube/MathematicaForPrediction/tree/master/Documentation/MappingSMRtoSBR), 
(2019),
[GitHub/antononcube](https://github.com/antononcube).

### Packages, repositories

[AAp1] Anton Antonov,
[ML::StreamsBlendingRecommender Raku package](https://github.com/antononcube/Raku-ML-StreamsBlendingRecommender),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Monadic Sparse Matrix Recommender Mathematica package](https://github.com/antononcube/MathematicaForPrediction/blob/master/MonadicProgramming/MonadicSparseMatrixRecommender.m),
(2018),
[GitHub/antononcube](https://github.com/antononcube/).

[AAp3] Anton Antonov,
[Sparse Matrix Recommender Monad R package](https://github.com/antononcube/R-packages/tree/master/SMRMon-R),
(2018),
[R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).

[AAp4] Anton Antonov,
[SparseMatrixRecommender Python package](https://github.com/antononcube/Python-packages/tree/main/SparseMatrixRecommender),
(2021),
[Python-packages at GitHub/antononcube](https://github.com/antononcube/Python-packages).

[MEp1] Marco Eidinger, 
[SwiftPlantUML](https://github.com/MarcoEidinger/SwiftPlantUML),
(2021-2022),
[GitHub/MarcoEidinger](https://github.com/MarcoEidinger).
