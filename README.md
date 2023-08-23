# manyweakiv
Linear instrumental variable regressions are widely used to estimate causal effects. Many instruments  arise from the use of "technical" instruments and more recently from the empirical strategy of "judge design".  Recent research highlights the need for a distinct approach to assess instrument strength when dealing with many instruments, diverging from the conventional first-stage F test intended for only a few instruments.

Inside this repository, you'll find two main commands: 

1. `manyweakivpretest`: This command is designed to evaluate the strength of instruments. Jack-knife IV estimator is reliable only if instruments are strong.
2. `manyweakiv`: This command conducts weak identification-robust inference.

Both methods draw from Mikusheva and Sun (2022, 2023). Importantly, they are valid in settings with many instruments and a general form of heteroscedasticity.

## Installation
**manyweakiv** can be installed easily via the `github` package, which is available at [https://github.com/haghish/github](https://github.com/haghish/github).  Specifically execute the following code in Stata:

`net install github, from("https://haghish.github.io/github/")`

To install the **manyweakiv** package , execute the following in Stata:

`github install lsun20/manyweakiv`

which should install the dependency packages and help files.

To update the **manyweakiv**  package, execute the following in Stata:

`github update manyweakiv`

Documentation is included in the Stata help file that is installed along with the package.  An empirical example is provided in the help file.

## Authors and acknowledgment
Liyang Sun

## References
Anna Mikusheva, Liyang Sun, [Inference with Many Weak Instruments](https://doi.org/10.1093/restud/rdab097), The Review of Economic Studies, Volume 89, Issue 5, October 2022, Pages 2663–2686, [Preprint](https://arxiv.org/abs/2004.12445).

Mikusheva, A. and Sun, L. 2023. [Weak Identification with Many Instruments](https://arxiv.org/abs/2308.09535). arXiv:2308.09535 [econ.EM]
