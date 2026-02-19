{smcl}
{* *! version 1.0.0  16jun2025}{...}
{viewerjumpto "Syntax" "tmle##syntax"}{...}
{viewerjumpto "Description" "tmle##description"}{...}
{viewerjumpto "Options" "tmle##options"}{...}
{viewerjumpto "Examples" "tmle##examples"}{...}
{viewerjumpto "Stored results" "tmle##results"}{...}
{viewerjumpto "References" "tmle##references"}{...}
{title:Title}

{phang}
{bf:tmle} - Estimate treatment effects using TMLE

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:tmle} {varlist} {ifin}, 
{opth omodel(string)} {opth tmodel(string)} [{opt opredict(string)} {opt tpredict(string)} {opt level(#)}]

{pstd}
where {varlist} consists of exactly two numeric variables: the outcome variable and the treatment variable.

{marker description}{...}
{title:Description}

{pstd}
{cmd:tmle} estimates the treatment effects using TMLE using the code adapted from Luque-Fernandez et al. (2018) and Frank & Karim (2023). 
It allows users to define the model specifications for the outcome ({opt omodel()}) and treatment ({opt tmodel()}), 
with optional specifications for predicted values and confidence level.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt omodel(string)} specifies the model for the outcome variable (e.g., GLM). This option is required.

{phang}
{opt tmodel(string)} specifies the model type for the treatment variable (e.g., GLM). This option is required.

{phang}
{opt opredict(string)} specifies the prediction options for the outcome variable (e.g., "mu").

{phang}
{opt tpredict(string)} specifies the prediction options for the treatment variable.

{phang}
{opt level(#)} sets the confidence level for confidence intervals. The default is 95.

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}. webuse cattaneo2{p_end}

{pstd}Estimate the average treatment effect (ATE) of smoking on low birthweight {p_end}
{phang2}. tmle lbweight mbsmoke, omodel(glm lbweight mbsmoke prenatal1 mmarried mage fbaby, fam(binomial)) tmodel(glm mbsmoke mmarried c.mage##c.mage fbaby medu, fam(binomial))
{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:tmle} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(ATE)}}ATE{p_end}
{synopt:{cmd:r(se)}}Standard error of ATE{p_end}
{synopt:{cmd:r(p)}}p-value{p_end}

{p2colreset}{...}

{marker references}{...}
{title:References}

{pstd}
Luque-Fernandez, M. A., Schomaker, M., Rachet, B., & Schnitzer, M. E. (2018). 
Targeted maximum likelihood estimation for a binary treatment: A tutorial. 
{it:Statistics in Medicine}, 37(16), 2530-2546. 
{browse "https://doi.org/10.1002/sim.7628":https://doi.org/10.1002/sim.7628}

{pstd}
Frank, H. A., & Karim, M. E. (2023). 
Implementing TMLE in the presence of a continuous outcome. 
{it:Research Methods in Medicine & Health Sciences}, 5(1), 8-19. 
{browse "https://doi.org/10.1177/26320843231176662":doi:10.1177/26320843231176662}

{title:Author}

{pstd}
Chao Wang, Kingston University
excelwang@gmail.com

{title:Also see}

{pstd}
Online: {helpb teffects}
{p_end}