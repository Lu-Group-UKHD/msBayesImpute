# msBayesImpute

**msBayesImpute** is a versatile framework for handling missing values in **mass spectrometry (MS) proteomics data**.  
It integrates **probabilistic dropout models** into a **Bayesian matrix factorization** framework, enabling robust, data-driven imputation.  

Key features:  
- Models both *missing at random (MAR)* and *missing not at random (MNAR)* values.  
- Learns dropout curves directly from the data, without predefined assumptions.  
- Works on both small and large datasets.  
- Available in **Python**, **R**, and via a **Shiny web interface**.  

This repository contains the **R package** of msBayesImpute, which is a wrapper of the Python implementation. [msBayesImpute (Python implementation)](https://github.com/Lu-Group-UKHD/msBayesImpute_Py).  

---

## Repository structure

```bash
msBayesImpute/
├── data/          # Example dataset (HeLa cell line proteomics data)
├── R/             # R wrapper scripts
├── man/           # Documentation for R functions
├── vignettes/     # Usage examples (see quick_guide_R.Rmd)
├── rshiny/        # Shiny web interface
├── msbayesimputepy-0.1.0-py3-none-any.whl   # Python wheel (remove before Bioconductor submission)
└── README.md
```

---

## Installation

### Python package

Install the Python package using `pip` (the `.whl` file is provided in this repository):  

```bash
pip install msbayesimputepy-0.1.0-py3-none-any.whl
```

---

### R package

Install the R package from source:  

```r
devtools::install_github("Lu-Group-UKHD/msBayesImpute")
```

**Note:** The R package uses the Python backend via [`reticulate`](https://rstudio.github.io/reticulate/).  
Please ensure that the Python environment specified in `reticulate` matches the one where `msbayesimputepy` was installed. Instructions for setting the Python environment can be found in the vignette **`quick_guide_R.Rmd`**.  

---

## Getting started

- See the vignette [`quick_guide_R.Rmd`](vignettes/quick_guide_R.Rmd) for a step-by-step guide to running msBayesImpute in R.  
- A Shiny app is provided in the `rshiny/` folder for users who prefer a graphical interface.  

---

## Citation

If you use **msBayesImpute** in your research, please cite:  
*He J, et al. bioRxiv (2025). msBayesImpute: A Versatile Framework for Addressing Missing Values in Biomedical Mass Spectrometry Proteomics Data*

---

