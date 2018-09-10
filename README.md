# diffusion_binding_simulations
Simulations used in the article: [Mapping Transient Protein Interactions at the Nanoscale in Living Mammalian Cells](https://pubs.acs.org/doi/10.1021/acsnano.8b01227) by [Herlinde De Keersmaecker](https://www.linkedin.com/in/herlinde-de-keersmaecker-a448b4b2/), [Rafael Camacho](https://camachodejay.github.io/), David Manuel Rantasa, Eduard Fron, Hiroshi Uji-i, Hideaki Mizuno, and [Susana Rocha](https://www.linkedin.com/in/susana-rocha-50020622/)

To get the simulated images used in the linear diffusion run mainSimulationDiffusion.m

To get the simulated images used for the binding kinetics run mainSimulationBinding.m

## Simulation's Logic

###Diffusion of single particles:
We simulated molecules diffusing linearly along the focal plane. The distance traveled by each molecule depends on the frame exposure and the diffusion speed. We generate the image via the following approximation: the molecule’s trajectory was sampled at 4ms time resolution. Then the particle’s point-spread-function (PSF) was placed at each of the sampled positions. Then the “motion blurred” image can be calculated by sampling this.

To calculate the PSF of a single particle we implemented the [PSF Generator from the Biomedical Imaging Group at EPFL]( http://bigwww.epfl.ch/algorithms/psfgenerator/). Note that each PSF is sampled according to the molecule’s brightness to obtain the number of counts per pixel on the imaging sensor. To approximate the noise properties of our detector (EMCCD camera) we measured the background level for each experimental condition and approximated it via a Gaussian model.

###Binding of particles to target site:
Further we simulated the interaction between a protein diffusing in the cytosol and a protein-binding pocket at the plasma membrane. This process was simulated by considering the following steps: (1) a fluorescent protein diffuses towards a pocket and binds with certain time constant; (2) Once bound, the molecule becomes fluorescent with a limited survival time on the “bright” state - given by the quenching time. (3) The molecule (bright or bleached) leaves the binding site. (4) The pocket becomes available once again. All this considered, we calculate the fraction of each camera frame in which the binding pocket was occupied by a bright fluorescent label, and use this information to generate the frame’s image.
