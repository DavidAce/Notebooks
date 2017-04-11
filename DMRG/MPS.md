# HOWTO
- (**Recommended**) [Open on StackEdit](https://stackedit.io/viewer#!url=https://raw.githubusercontent.com/DavidAce/Notebooks/master/DMRG/MPS.md), an online open-source markdown+tex editor.
- Install a MathJax renderer for your browser to read directly on the GitHub webpage. For instance, [Github with MathJax](https://chrome.google.com/webstore/detail/github-with-mathjax/ioemnmodlmafdkllaclgeombjnmnbima).
- Open this file on your pc/mac with the [`Atom`](https://atom.io/) editor with the `markdown-preview-plus` -plugin installed.
- Open this file on your pc/mac with the [`ReText`](https://github.com/retext-project/retext) editor. To get inline equations showing nicely, do the following (copy-paste to terminal):
    - `sudo apt install python3-pyqt5.qtwebkit`
    - `echo "mathjax" >> ~/.config/markdown-extensions.txt`.
    - Finally enable webkit inside ReText: `Edit -> Use WebKit Renderer`.




[TOC]

# Matrix Product States

There are two alternative ways to prepare MPS. The first is by using successive Schmidt decompositions, which as it turns out also produces MPS in *canonical form*. The second is a preparation from maximally entangled pairs, the so called valence bonds states.



## Canonical form (from [Jens paper](http://journals.aps.org/prb/abstract/10.1103/PhysRevB.87.235106))

A general quantum state $|\psi\rangle$ on a chain with N sites can be written in MPS form:


$$
\begin{equation}
|\psi\rangle = \sum_{\sigma_1...\sigma_N} A^{\sigma_1}...A^{\sigma_N}|\sigma_1...\sigma_N\rangle,
\end{equation}
$$




where $A^{\sigma_i}$ is a $r_{i-1}\times r_{i}$ matrix, $r_i$ being the rank of the Schmidt decomposition at site $i$. Note that at the boundary we have $r_0 = r_N = 1$, which means that $A^{\sigma_1}$ and $A^{N}$ are vectors, and therefore the matrix product returns a scalar coefficient.

We can rewrite the matrices $A^{\sigma_i}$ as a product of $r_{i-1}\times r_i$ complex matrices $\Gamma^{\sigma_i}$ and positive, real, square diagonal matrices $\Lambda^i$



$$
\begin{equation}
|\psi\rangle = \sum_{\sigma_1...\sigma_N} \Gamma^{\sigma_1}\Lambda^1\Gamma^{\sigma_2}\Lambda^2...\Lambda^{N-1}\Gamma^{\sigma_N}|\sigma_1...\sigma_N\rangle,
\end{equation}
$$


which diagrammatically looks like

<img class="center-block" height="50px" src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/tensortrain.png">

This form allows for many possible representations of the same wave function, giving us the opportunity to define a “canonical form” of the MPS.

We can define a set of $\chi_n$ wave functions $|\alpha\rangle_{L/R}^n$ to the left/right of a bond, such that


$$
\begin{equation}
|\psi\rangle = \sum_{\alpha=1}^\chi \Lambda_\alpha^n |\alpha\rangle^n_L\otimes |\alpha\rangle^n_R , \quad |\alpha\rangle \in H_{L/R}
\end{equation}
$$

---

**The MPS representation $\{\Gamma^{\sigma_1} \Lambda^1\Gamma^{\sigma_2} \Lambda^2...\Lambda^{N-1} \Gamma^{\sigma_N}\}$ is canonical if for every bond, the set of wave functions $|\alpha\rangle_{L/R}^n$ along with $\Lambda^i$ form a Schmidt decomposition of $\psi$.
In other words we must have $\langle \hat{\alpha}|\alpha\rangle^n_L = \delta_{\hat{\alpha}\alpha}$, $\langle \hat{\alpha}|\alpha\rangle^n_R  = \delta_{\hat{\alpha}\alpha}$ and $\sum {\Lambda_{\alpha}^i}^2 = 1$ on every bond. Equivalently, $A^{\sigma_i\dagger}A^{\sigma_i} = \mathbf{1}$.**

---



## Schmidt decomposition according to Vidal

---

> **Summary from the following papers**
>
> [Vidal, G. (2003). Efficient Classical Simulation of Slightly Entangled Quantum Computations. Physical Review Letters, 91(14), 147902.](https://doi.org/10.1103/PhysRevLett.91.147902)
>
> [Vidal, G. (2004). Efficient simulation of one-dimensional quantum many-body systems. Physical Review Letters, 93(4), 40502–1.](https://doi.org/10.1103/PhysRevLett.93.040502)

---

The local decomposition of the state $|\psi\rangle \in H_2^{\otimes n}$ in terms of $n$ tensors $\{\Gamma^{\sigma_l}\}^n_{l=1}$ and $\{\lambda^{l}\}^{n-1}_{l=1}$ is denoted


$$
\begin{equation}
|\psi\rangle \leftrightarrow \Gamma^{\sigma_1}\lambda^1\Gamma^{\sigma_2}\lambda^2...\lambda^{n-1}\Gamma^{\sigma_n}
\end{equation}
$$


Here, tensor $\Gamma^{\sigma_l}$ has at most three indices $\Gamma^{\sigma_1}_{\alpha\alpha^\prime}$, where $\alpha,\alpha^\prime = 0,...,\chi$ and $\sigma_l = 0,1$, whereas $\lambda^l$ is a vector whose components $\lambda^l_{\alpha^\prime}$ store the Schmidt coefficients of the splitting $[1...l]:[(l+1)...n]$. More explicitly we have


$$
\begin{equation}
c_{\sigma_1...\sigma_n}= \sum_{\alpha_1...\alpha_{n-1}} \Gamma^{\sigma_1}_{\alpha_1}\lambda^1_{\alpha_1}\Gamma^{\sigma_2}_{\alpha_1\alpha_2}\lambda^1_{\alpha_2}...\Gamma^{\sigma_n}_{\alpha_{n-1}}
\end{equation}
$$


so that $2^n$ coefficients in $c_{\sigma_1...\sigma_n}$ are expressed in terms of about $(2\chi^2 + \chi)n$ parameters, a number that grows linearly in $n$ for a fixed value of $\chi$.

## Procedure
This is essentially a concatenation of $n-1$ Schmidt decompositions, and depends on how the qubits have been ordered from $1$ to $n$. We first compute the Schmidt decomposition according to the bipartite splitting of $|\psi\rangle$ into qubit $1$ and the $n-1$ remaining qubits.



$$
\begin{equation}
|\psi\rangle = \sum_{\alpha_1} \lambda_{\alpha_1}^1 |\Phi_{\alpha_1}^1\rangle|\Phi_{\alpha_1}^{2...n}\rangle = \sum_{\sigma_1,\alpha_1}\Gamma^{\sigma_1}_{\alpha_1}\lambda^{1}_{\alpha_1}|\sigma_1\rangle|\Phi_{\alpha_1}^{2...n}\rangle
\end{equation}
$$


We then proceed according to the following three steps:

1.  Expand each vector $|\Phi_{\alpha_1}^{2...n}\rangle$ in a local basis for qubit 2, $|\Phi_{\alpha_1}^{2...n}\rangle =\sum_{\sigma_2}|\sigma_2\rangle |\tau_{\alpha_1,\sigma_2}^{3...n}\rangle$
2.  Write each vector $|\tau_{\alpha_1,\sigma_2}^{3...n}\rangle$ in terms of at most $\chi$ Schmidt vectors $\{|\Phi_{\alpha_2}^{3...n}\rangle\}_{\alpha_2}^\chi$, i.e. eigenvectors of $\rho^{3...n}$ and the corresponding Schmidt coefficients $\lambda_{\alpha_2}^2$: $|\tau_{\alpha_1,\sigma_2}^{3...n}\rangle = \sum_{\alpha_2}\Gamma_{\alpha_1\alpha_2}^{\sigma_2}\lambda_{\alpha_2}^2|\Phi_{\alpha_2}^{3...n}\rangle$
3.  Substitute the equations in (1) and (2) into the first splitting above, i.e.:


$$
\begin{align}
|\Phi_{\alpha_1}^{2...n}\rangle &=\sum_{\sigma_2}|\sigma_2\rangle  \sum_{\alpha_2}\Gamma_{\alpha_1\alpha_2}^{\sigma_2}\lambda_{\alpha_2}^2|\Phi_{\alpha_2}^{3...n}\rangle \\
&=\sum_{\sigma_2,\alpha_2} \Gamma_{\alpha_1\alpha_2}^{\sigma_2}\lambda_{\alpha_2}^2|\sigma_2\rangle |\Phi_{\alpha_2}^{3...n}\rangle
\end{align}
$$


followed by


$$
\begin{align}
|\psi\rangle &= \sum_{\sigma_1,\alpha_1}\Gamma^{\sigma_1}_{\alpha_1}\lambda^{1}_{\alpha_1}|\sigma_1\rangle\sum_{\sigma_2}|\sigma_2\rangle  \sum_{\alpha_2}\Gamma_{\alpha_1\alpha_2}^{\sigma_2}\lambda_{\alpha_2}^2|\Phi_{\alpha_2}^{3...n}\rangle \\
&=\sum_{\sigma_1\sigma_2,\alpha_1\alpha_2}\Gamma^{\sigma_1}_{\alpha_1}\lambda^{1}_{\alpha_1}  \Gamma_{\alpha_1\alpha_2}^{\sigma_2}\lambda_{\alpha_2}^2|\sigma_1\rangle|\sigma_2\rangle|\Phi_{\alpha_2}^{3...n}\rangle
\end{align}
$$

Repeating steps 1 to 3 for the Schmidt vectors $|\Phi_{\alpha_3}^{4...n}\rangle , |\Phi_{\alpha_4}^{5...n}\rangle...$ gives us the state $|\psi\rangle$ in terms of tensors $\Gamma^{\sigma_l}$ and $\lambda^l$.

---

### Remarks on implementation in code
Basically, to begin a decomposition we do a mode-1 unfolding to write the tensor in matrix form $c_{\sigma_1...\sigma_N} \rightarrow c_{\sigma_1,\sigma_2...\sigma_N}$. See below for details on unfolding. The resulting matrix undergoes an SVD decomposition to get $USV^\dagger$, where we then set $US = \Gamma\lambda$.

Steps 1. and 2. above then amount to taking $V^\dagger$ and **doing the mode-1 unfolding backwards**, giving something like $V^{\dagger}_{\sigma_1...\sigma_N}$, and then refolding into $V^\dagger_{\sigma_1\sigma_2,\sigma_3...\sigma_N}$.

The reason for taking the extra step back and forth is to avoid having to keep track on which reshaping algorithm is being used; any reshaping order will do!

 


### Tensor decomposition (matrix unfolding)


There are more details on higher-order tensor decomposition (matrix unfolding) here:
[De Lathauwer, L., De Moor, B., & Vandewalle, J. (2000). A Multilinear Singular Value Decomposition. - Society for Industrial and Applied Mathematics. Journal on Matrix Analysis and Applications](http://epubs.siam.org/doi/pdf/10.1137/S0895479896305696)

<img class="center-block" height="450px" src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/matrixunfolding.png">

And also here:

[Bengua, J. a., Phien, H. N., Tuan, H. D., & Do, M. N. (2015). Matrix Product State for Feature Extraction of Higher-Order Tensors, (1944), 10.](http://arxiv.org/abs/1503.0516)

<img class="center-block" height="200px" src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/matrixunfolding_algorithm.png">
<img class="center-block" height="350px" src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/matrixunfolding_algorithm2.png">



$$
\begin{array}{c c}\fbox{NOTE: The method above works best for decompositions from the right. } \\ \fbox{We want neighboring qubits to pick the "largest" subsections of the flattened matrix!} \\ \text{To go from the left, define instead } J_k =  \prod_{m=1, m\neq n}^{N-k} I_m  \\ 
\fbox{Notice the product limits!} \\ \fbox{Let's call this the "Left-method", for decompositions from the left, and the other one the "Right-method". } 
\end{array}
$$

---


### Local updates

Updating the state $|\psi\rangle$ after a unitary operation $U$ acts on qubit $l$ does only involve transforming $\Gamma^{\sigma_l}$. The computational cost is $\mathcal{O}(\chi^2)$ basic operations.

When a unitary operation $V$, like a two-qubit gate, is applied to qubits $l$ and $l+1$ only $\Gamma^{\sigma_l}, \lambda^l \text{ and } \Gamma^{\sigma_{l+1}}$ need to be updated. The computational cost is $\mathcal{O}(\chi^3)$ basic operations.



### Example 1 (Not thorough): Three Qubits, following Schollwoeck
This example tries to follow the steps in
[Schollwoeck, U. (2010). The density-matrix renormalization group in the age of matrix product states. Annals of Physics, 326(1), 96192.](https://doi.org/10.1016/j.aop.2010.09.012)


**Step 1:**

In general, a 3 qubit state can be written as:


$$
\begin{equation}
|\psi\rangle = \sum_{\sigma_1\sigma_2\sigma_3} c_{\sigma_1 \sigma_2 \sigma_3} |\sigma_1\sigma_2\sigma_3\rangle,
\end{equation}
$$


where each $\sigma_i\in \{0,1\}$ and the coefficients $c_{\sigma_1 \sigma_2 \sigma_3}$ are $2^3$ complex numbers. These numbers can be visualized as being on the corners of a (hyper)cube, or simply a long list of numbers corresponding to the 8 possible states.

Consider the following state with 3 qubits: $|\psi\rangle = \frac{1}{\sqrt{2}} ( |010\rangle + |101\rangle)$. The cube would look as in the figure below.

<img class="center-block" height="150px" src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/cube.jpg">


or simply,

$$
\begin{array}{c|c}   0 & |000\rangle  \\    0 & |001\rangle \\   2^{-1/2} & |010\rangle \\     0 & |011\rangle \\ 0 & |100\rangle \\ 2^{-1/2} & |101\rangle \\ 0 & |110\rangle \\ 0 & |111\rangle
\end{array}
$$



The first step in the decomposition is to define a $d\times d^{L-1} = 2\times 2^2$ matrix that flattens the tensor:


$$
\begin{equation}
\Psi_{\sigma_1,(\sigma_2\sigma_3)} =
\begin{array}{c|c c c c}
    & \mathbf{\sigma_1 = 0, \sigma_3 = 0} & \mathbf{\sigma_1 = 0, \sigma_3 = 1} & \mathbf{\sigma_1 = 1, \sigma_3 = 0 }& \mathbf{\sigma_1 = 1, \sigma_3 = 1} & \\ \mathbf{\sigma_2 = 0} & 0 & 0 & 0 & 2^{-1/2} \\ \mathbf{\sigma_2 = 1} & 2^{-1/2} & 0 &0 & 0  
\end{array}
=
\begin{pmatrix} 0 & 0 & 0 & 2^{-1/2} \\ 2^{-1/2} & 0 & 0 & 0
\end{pmatrix}
\end{equation}
$$



Note how the cube has been sliced and concatenated. Basically, the matrix is composed of two $(2\times 2)$ matrices side by side, one for each value of $\sigma_1$.

Now we perform the single value decomposition on  $\Psi_{\sigma_1,(\sigma_2\sigma_3)} = USV^\dagger$:


$$
\begin{align}
\begin{pmatrix}
  0 & 0 & 0 & 2^{-1/2} \\
  2^{-1/2} & 0 & 0 & 0
\end{pmatrix}
&=\begin{pmatrix}
  1 & 0 \\
  0 & 1
\end{pmatrix}
\begin{pmatrix}
  2^{-1/2} & 0 \\
  0 & 2^{-1/2}
\end{pmatrix}
\begin{pmatrix}
  0 & 0 & 0 & 1 \\
  1 & 0 & 0 & 0  
\end{pmatrix} \\
&= \sum_{a_1}^{r_1} U_{\sigma_1, a_1} S_{a_1,a_1} V^\dagger_{a_1,\sigma_2\sigma_3} \\
&\equiv \sum_{a_1}^{r_1} U_{\sigma_1,a_1} c_{a_1,\sigma_2\sigma_3}
\end{align}
$$


where $r_1\leq d=2$ is the rank of the decomposition, i.e., the number of nonzero items in $S$, and $a_1 \in \{0,1\}$. In the last equality $S$ and $V^\dagger$ have been multiplied. It can then be reshaped into a matrix of dimension $(r_1d\times d) = (4\times 2)$, called $\Psi_{(a_1\sigma_2),(\sigma_3)}$. This is NOT done by stacking the $(2\times 2)$ matrices. Instead, note how the $\sigma_2$ index selects the upper/lower row, which then become matrices. Pythons numpy.reshape() does this.  **Here the label** $a_1$**is the index being summed over (by matrix multiplication), and** $\sigma_2,\sigma_3$ **serve to select appropriate matrices.**



$$
\begin{equation}
c_{a_1,\sigma_2\sigma_3} =
\begin{pmatrix} 0 & 0 & 0 & 2^{-1/2} \\ 2^{-1/2} & 0 & 0 & 0  \end{pmatrix}
\rightarrow
\begin{pmatrix}
  \begin{pmatrix} \binom{0}{0}&\binom{0}{2^{-1/2}}\end{pmatrix}_{\sigma_3}\\
  \begin{pmatrix} \binom{2^{-1/2}}{0} &\binom{0}{0}\end{pmatrix}_{\sigma_3}
\end{pmatrix}_{\sigma_2}
=\Psi_{(a_1\sigma_2),(\sigma_3)}
\end{equation}
$$


$U$ is now sliced into $d=2$ row vectors $A^{\sigma_1}$, which we interpret as $(1\times 2)$ matrices, i.e., $A^{\sigma_1}_{a_1}=U_{\sigma_1,a_1} \rightarrow \begin{pmatrix}\begin{pmatrix}1&0\end{pmatrix}\\ \begin{pmatrix}0&1\end{pmatrix}\end{pmatrix}_{\sigma_1}$, where $\sigma_1$ labels each row vector.

By now we have achieved the following:



$$
\begin{equation}
c_{\sigma_1\sigma_2\sigma_3} = \sum_{a_1}^{r_1} A^{\sigma_1}_{a_1} \Psi_{(a_1\sigma_2),(\sigma3)}
=
\begin{pmatrix}
  \begin{pmatrix}1&0\end{pmatrix}\\
  \begin{pmatrix}0&1\end{pmatrix}
\end{pmatrix}_{\sigma_1}
\begin{pmatrix}
  \begin{pmatrix}\binom{0}{0}&\binom{0}{2^{-1/2}}  \end{pmatrix}_{\sigma_3}\\  \begin{pmatrix} \binom{2^{-1/2}}{0} &\binom{0}{0} \end{pmatrix}_{\sigma_3}
\end{pmatrix}_{\sigma_2}
\end{equation}
$$


where the labels $\sigma_1,\sigma_2,\sigma_3$ serve to index the inner elements.

So for instance if $|\sigma_1 \sigma_2 \sigma_3 \rangle = |101\rangle$ we get $c_{101} = (0,1)\binom{0}{2^{-1/2}} = 2^{-1/2}$ as expected (check this!).


**Step 2:**

Next, we apply the SVD decomposition once more


$$
\begin{align}
\Psi_{(a_1\sigma_2),(\sigma_3)} = U S V^\dagger &=
\begin{pmatrix}0 & 0 \\ 0 &1 \\ -1 & 0 \\ 0 & 0\end{pmatrix}
\begin{pmatrix}2^{-1/2} &0 \\ 0 & 2^{-1/2} \end{pmatrix}
\begin{pmatrix} -1 &0 \\ 0 & 1 \end{pmatrix} \\
&= \sum_{a_2}^{r_2}U_{(a_1\sigma_2),a_2}S_{a_2,a_2}(V^\dagger)_{a_2,(\sigma_3)} \\
&=\sum_{a_2}^{r_2} A_{a_1,a_2}^{\sigma_2} \Psi_{a_2\sigma_3}
\end{align}
$$


where $U$ is replaced by a set of $d$ matrices $A^{\sigma_2}$ of dimension $r_1\times r_2 = (2\times 2)$ with entries $A^{\sigma_2}_{a_1,a_2} = U_{(a_1\sigma_2),a_2}$. As before, $SV^\dagger$ has been reshaped into a matrix $\Psi$ of dimension $r_2d\times d^{L-3} = (4\times 1)$.

Explicitly, this reads:

$$
\begin{equation}
\sum_{a_2}^{r_2} A_{a_1,a_2}^{\sigma_2} \Psi_{a_2\sigma_3}
=
\begin{pmatrix}
  \begin{pmatrix}0 & 0 \\ 0 & 1 \end{pmatrix} \\
  \begin{pmatrix}-1 & 0\\ 0 & 0 \end{pmatrix}
\end{pmatrix}_{\sigma_2}
\begin{pmatrix}\binom{-2^{-1/2}}{0} \\ \binom{0}{2^{-1/2}} \end{pmatrix}_{\sigma_3}
\end{equation}
$$

So far we have achieved the following:

$$
\begin{equation}
c_{\sigma_1\sigma_2\sigma_3} = \sum_{a_1,a_2}^{r_1,r_2} A^{\sigma_1}_{a_1} A^{\sigma_2}_{a_1,a_2} \Psi_{a_2\sigma_3}
\end{equation}
$$

So for instance $c_{101} = A^{\sigma_1 = 1}A^{\sigma_2=0}\Psi_{a_2\sigma_3=1} = (0,1)\begin{pmatrix}0 & 0 \\ 0 & 1 \end{pmatrix}\binom{0}{2^{-1/2}}= 2^{-1/2}$, as expected.

Step 3:
We perform the SVD decomposition for the last time:


$$
\begin{equation}
\Psi_{(a_1\sigma_2),(\sigma_3)} = U S V^\dagger =  \begin{pmatrix} -2^{-1/2}\\0 \\ 0 \\2^{-1/2} \end{pmatrix} \times 1 \times 1
\end{equation}
$$


where as before we split $U$ into a collection of $d$ vectors with elements $A^{\sigma_3}_{a_2} = U_{(a_2\sigma_3)}$.


Following the previous prescription, we set $A^{\sigma_3} = \begin{pmatrix}\binom{-2^{-1/2}}{0} \\ \binom{0}{2^{-1/2}} \end{pmatrix}_{\sigma_3}$, and we are done.

We now have


$$
\begin{equation}
|\psi\rangle=\sum_{\sigma_1\sigma_2\sigma_3} c_{\sigma_1\sigma_2\sigma_3}|\sigma_1\sigma_2\sigma_3\rangle = 
\sum_{a_1,a_2,a_3}^{r_1,r_2,r_3}A^{\sigma_1}_{a_1}A^{\sigma_2}_{a_1,a_2}A^{\sigma_3}_{a_3} |\sigma_1\sigma_2\sigma_3\rangle
\end{equation}
$$


where


$$
\begin{align}
A_{\alpha_1}^{\sigma_1} &= \{(1,0) , (0,1)\}\\
A_{\alpha_1\alpha_2}^{\sigma_2} &= \{\begin{pmatrix}0&0\\0&1\end{pmatrix} , \begin{pmatrix}-1&0\\0&0\end{pmatrix} \} \\
A_{\alpha_2}^{\sigma_3} &= \{\begin{pmatrix}-2^{-1/2}\\0\end{pmatrix} , \begin{pmatrix}0\\2^{-1/2}\end{pmatrix} \}
\end{align}
$$

**Remark on Normalization**
It would seem that it is simpler to do the decomposition for unnormalized states using ones everywhere, and then normalize by $1/\sqrt{2}$  perhaps?



[comment]:&lt;> "<iframe height='260' width='400' src="https://www.youtube.com/embed/Q8bFmV6tHBs" frameborder="0" allowfullscreen align="middle"></iframe>"

### Example 2: Four Qubits, following Vidal 

Let $|\psi\rangle = \frac{1}{\sqrt{3}}(|1110\rangle + |0011\rangle + |1010\rangle)$


We do a bipartite splitting on the first qubit,


$$
\begin{equation}
|\psi\rangle
=
\sum_{\alpha_1} \lambda_{\alpha_1}^1 |\Phi_{\alpha_1}^1\rangle|\Phi_{\alpha_1}^{\sigma_2\sigma_3\sigma_4}\rangle =
\sum_{\sigma_1,\alpha_1}\Gamma^{\sigma_1}_{\alpha_1}\lambda^{1}_{\alpha_1}|\sigma_1\rangle|\Phi_{\alpha_1}^{\sigma_2\sigma_3\sigma_4}\rangle
\end{equation}
$$



where $\Gamma_{\alpha_1}^{\sigma_1}$ comes from the SVD decomposition and $\lambda_{\alpha_1}^1$ are the corresponding singular values, or Schmidt coefficients.

**Preliminaries: Mode-1 unfolding (Left method)**

To actually perform the SVD decomposition initially, the tensor $c_{\sigma_1...\sigma_4}$ needs to be flattened, or matricized.

We begin by doing a *mode-1* matrix unfolding (or flattening), where we get a matrix $\Psi_{i_1,j} = \Psi_{\sigma_1,(\sigma_2...\sigma_4)} \in \mathbb{R}^{2\times(2\cdot2\cdot2)}$. Note that $i_k$ and $j$ denotes the tensor indices, i.e. $i_k \in 1, 2,..., I_k$, and $j \in 1,2,...,(\prod_{m\neq k}^n I_m)$. An $I_k$ is simply the dimensions of a qubit at $k$, i.e. 2.


The tensor $c_{\sigma_1...\sigma_4}$ has nonzero elements $c_{1100}, c_{0011} \text{ and } c_{1010}$ which, in a mode-1 unfolding, maps to matrix coordinates

Using the "Left-method" (see earlier in this section), the tensor $c_{\sigma_1...\sigma_4}$ maps to matrix coordinates


- $c_{1110} \rightarrow \Psi_{i_1 = 2,j=7}$. Here $j =1 + \sum_{k\neq 1}^4 (i_k -1)J_k$ with $J_k = \prod_{m\neq1}^{N-k} I_m$. We can use qubit values directly, by instead rewriting $j =1 + \sum_{k\neq 1}^4 \sigma_kJ_k$. This gives $j = 1+ \sigma_2J_2 + \sigma_3J_3 + \sigma_4J_4 = 1 + 1*4 + 1*2 + 0*1 = 7$.

- $c_{0011} \rightarrow \Psi_{i_1=1,j=4}$ Using the same method as above we get $j = 1+0*4 + 1*2 + 1*1 = 4$.

- $c_{1010} \rightarrow {\Psi_{i_1=2,j=3}}$. And again, $j = 1+0*4 + 1*2 + 0*1 = 3$.

Reinserting the normalization factor we get


$$
\begin{equation}
\Psi_{\sigma_1,(\sigma_2\sigma_3\sigma_4)} = \frac{1}{\sqrt{3}}\begin{pmatrix}0&0&0&1_{0011}&0&0&0&0 \\ 0&0&1_{1010}&0&0&0&1_{1110}&0\end{pmatrix}
\end{equation}
$$

which goes into the first SVD iteration.

**First SVD**

The SVD decomposition of $\Psi_{\sigma_1,(\sigma_2\sigma_3\sigma_4)} $ yields:


$$
$$\begin{align}
U &= \begin{pmatrix}0&1 \\ 1&0\end{pmatrix}\\
S &= \frac{1}{\sqrt{3}}\begin{pmatrix}\sqrt{2}&0 \\ 0&1\end{pmatrix}\\
V^\dagger &= \frac{1}{\sqrt{2}}\begin{pmatrix}0&0&1&0&0&0&1&0 \\ 0&0&0&\sqrt{2}&0&0&0&0\end{pmatrix}
\end{align}$$
$$


where we can identify $\Gamma_{\alpha_1}^{\sigma_1} = U$ ($\sigma_1$ labels the row-vectors in $U$), and $\lambda^1_{\alpha_1} = \{\sqrt{\frac{2}{3}}, \frac{1}{\sqrt{3}}\}$. We arrive at

$$
\begin{equation}
|\psi\rangle =
\sum_{\alpha_1} \lambda_{\alpha_1}^1 |\Phi_{\alpha_1}^1\rangle|\Phi_{\alpha_1}^{\sigma_2\sigma_3\sigma_4}\rangle =
\sum_{\sigma_1,\alpha_1}\Gamma^{\sigma_1}_{\alpha_1}\lambda^{1}_{\alpha_1}|\sigma_1\rangle|\Phi_{\alpha_1}^{\sigma_2\sigma_3\sigma_4}\rangle,
\end{equation}
$$

and we identify $|\Phi_{\alpha_1}^{\sigma_2\sigma_3\sigma_4}\rangle$ as 

$$
\begin{equation}
SV^\dagger = \frac{1}{\sqrt{3}}\begin{pmatrix}0&0&1&0&0&0&1&0 \\ 0&0&0&1&0&0&0&0\end{pmatrix}.
\end{equation}
$$





To continue, we slice $|\Phi_{\alpha_1}^{\sigma_2\sigma_3\sigma_4}\rangle$ for each possible value of $\sigma_2$, i.e., two $(2\times 4)$ matrices, with $\alpha_1$ labeling the rows. In Vidal's notation

$$
\begin{align}
|\tau^{\sigma_3\sigma_4}_{\alpha_1,\sigma_2 = 0}\rangle &=  \frac{1}{\sqrt{3}}\begin{pmatrix}0&0&1_{1010}&0 \\ 0&0&0&1_{0011}\end{pmatrix} \\
|\tau^{\sigma_3\sigma_4}_{\alpha_1,\sigma_2 = 1}\rangle &=  \frac{1}{\sqrt{3}}\begin{pmatrix}0&0&1_{1110}&0 \\ 0&0&0&0\end{pmatrix}
\end{align}
$$




We finish this step by stacking these matrices into a $(4 \times 4)$ matrix

$$
\begin{equation}
|\tau^{\sigma_3\sigma_4}_{\alpha_1,\sigma_2}\rangle =  \frac{1}{\sqrt{3}}\begin{pmatrix}0&0&1&0 \\  0&0&0&1\\ 0&0&1&0\\ 0&0&0&0\end{pmatrix},
\end{equation}
$$

which goes into the next step.


**Second SVD**

The SVD decomposition of $|\tau^{\sigma_3\sigma_4}_{\alpha_1,\sigma_2}\rangle$ yields:


$$
\begin{align}
U &= \frac{1}{\sqrt{2}}\begin{pmatrix}1&0&0&-1   \\ 0&\sqrt{2}&0&0 \\ 1&0&0&1 \\0&0&\sqrt{2}&0\end{pmatrix}\\
S &= \frac{1}{\sqrt{3}}\begin{pmatrix}\sqrt{2}&0&0&0 \\ 0&1&0&0 \\ 0&0&0&0 \\ 0&0&0&0\end{pmatrix}\\
V^\dagger &= \begin{pmatrix}0&0&1&0 \\ 0&0&0&1 \\ 0&1&0&0\\ 1&0&0&0\end{pmatrix}
\end{align}
$$

Like the previous step, we identify $\Gamma_{\alpha_1,\alpha_2}^{\sigma_2} = U$, where $\sigma_2$ labels upper/lower $(2 \times 4)$ submatrices, and $\lambda^{\sigma_2}_{\alpha_2} = \{\sqrt{\frac{2}{3}}, \frac{1}{\sqrt{3}},0,0\}$.

Furthermore, we set $|\Phi_{\alpha_2}^{\sigma_3\sigma_4} \rangle = SV^\dagger$ and split again for each possible value of $\sigma_3$:

$$
\begin{align}
|\tau^{\sigma_4}_{\alpha_2,\sigma_3 = 0}\rangle &=  \frac{1}{\sqrt{3}}\begin{pmatrix}0&0 \\0&0 \\0 & 1\\ 1 & 0\end{pmatrix} \\
|\tau^{\sigma_4}_{\alpha_2,\sigma_3 = 1}\rangle &=  \frac{1}{\sqrt{3}}\begin{pmatrix}1&0 \\0&1 \\0 & 0\\ 0 & 0\end{pmatrix}
\end{align}
$$

In stacked matrix form this becomes 

$$
\begin{equation}
|\tau^{\sigma_4}_{\alpha_2,\sigma_3}\rangle =  \frac{1}{\sqrt{3}}\begin{pmatrix}0&0 \\0&0 \\0 & 1\\ 1 & 0\\ 1&0 \\0&1 \\0 & 0\\ 0 & 0\end{pmatrix}
\end{equation}
$$

which in turn feeds into the next iteration

**Third SVD**

The SVD decomposition of $|\tau^{\sigma_4}_{\alpha_2,\sigma_3}\rangle $ yields:


$$
\begin{align}
U &= \frac{1}{\sqrt{2}}\begin{pmatrix}1&0&0&-1   \\ 0&\sqrt{2}&0&0 \\ 1&0&0&1 \\0&0&\sqrt{2}&0\end{pmatrix}\\
S &= \frac{1}{\sqrt{3}}\begin{pmatrix}\sqrt{2}&0&0&0 \\ 0&1&0&0 \\ 0&0&0&0 \\ 0&0&0&0\end{pmatrix}\\
V^\dagger &= \begin{pmatrix}0&0&1&0 \\ 0&0&0&1 \\ 0&1&0&0\\ 1&0&0&0\end{pmatrix}
\end{align}
$$


### Example with PBC



---

## Virtual systems: Valence bonds or Maximally entangled pairs

---

> The following is a summary of this [presentation](http://www.pks.mpg.de/~esicqw12/Talks_pdf/Verstraete.pdf) and
>
> [Wahl, T. B. (2015). Tensor network states for the description of quantum many-body systems. arXiv Preprint, (August), 156.](http://arxiv.org/abs/1509.05984)
>
> [Pérez-García, D., Verstraete, F., Wolf, M. M., & Cirac, J. I. (2007). Matrix Product State Representation. Quantum Inf. Comp., 7, 401.](https://doi.org/10.1143/JPSJ.81.074003)
>
> [Saberi, H. (2008). Matrix-product states for strongly correlated systems and quantum information processing. Dissertation, 141.](https://edoc.ub.uni-muenchen.de/9755/1/Saberi_Hamed.pdf)

---


On a spin-$S$ chain of length $N$, replace each $d$-dimensional system $|\sigma_i\rangle$ at site $i$, with two *virtual systems* $|l_i,r_i\rangle$ of dimension $D_i=1+2S'$, called the bond dimension. These are sometimes called *auxiliary* systems. In general $D_i$ can be different for each site but it it needs to be larger than the bond dimension. Note that $l$ and $r$ stand for left and right.


<img class="center-block" height="150px" src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/valence.png">


Let every pair of virtual systems be maximally entangled with the respective neighboring system. This means that $r_i = l_{i+1} = \alpha_i$. The states are written in the form:


$$
\begin{equation}
|I_{i,i+1}\rangle = \sum_{\alpha_i=1}^D |r_i=\alpha_i,l_{i+1}=\alpha_i\rangle
\end{equation}
$$

And for the whole chain:

$$
\begin{equation}
|I\rangle = \sum_{\alpha_1,\alpha_2,...,\alpha_{N-1}}|\alpha_0,\alpha_1\rangle|\alpha_1,\alpha_2\rangle...|\alpha_{N-1},\alpha_N\rangle
\end{equation}
$$

where each sum denotes an *entangled bond*. **Note that without PBC the leftmost and rightmost sites have only one virtual particle**.

Then, apply a map

$$
\mathcal{A}^i = \sum_{\sigma_i} \sum_{l_i,r_i} A^{\sigma_i}_{l_i,r_i}|\sigma_i\rangle\langle l_i,r_i|
$$

to each of the $N$ sites. We then obtain the MPS

$$
|\psi\rangle = (\bigotimes_i^N \mathcal{A}^i)(\bigotimes_i^{N-1} |I_{i,i+1}\rangle)= \sum_{\sigma_1...\sigma_N} A^{\sigma_1}...A^{\sigma_N} |\sigma_1...\sigma_N\rangle
$$




### Example using valence bonds:

As before, let $|\psi\rangle = \frac{1}{\sqrt{2}}(|010\rangle + |101\rangle)$ be the state of 3 qubits, $d = 2$.

Let each site be replaced by pairs of dimension $D=2$ in a maximally entangled state, i.e. rewrite it in the (unnormalized) form:

$$
\begin{align}
|I_{1,2} \rangle &=
\sum_{\alpha_1} |r_1 = \alpha_1, l_2=\alpha_1\rangle = |0,0\rangle_{r_1,l_2} + |1,1\rangle_{r_1,l_2} \\
|I_{2,3} \rangle &=
\sum_{\alpha_2} |r_2 = \alpha_2, l_3=\alpha_2\rangle = |0,0\rangle_{r_2,l_3} + |1,1\rangle_{r_2,l_3}
\end{align}
$$


where the subscripts $r_i,l_i$ are there to remind us that this is the right and left virtual particles corresponding to site $i$. Now apply the map $\mathcal{A}$ on each site. :

$$
\begin{align}
\mathcal{A}^1|I_{1,2}\rangle &=
\sum_{\sigma_1}\sum_{r_1}A^{\sigma_1}_{r_1}|\sigma_1\rangle\langle r_1|(\sum_{\alpha_1}|\alpha_1,\alpha_1\rangle)\\
&= \sum_{\sigma_1} A_0^{\sigma_1} |\sigma_1\rangle _{r_1}\langle 0|0,0\rangle_{r_1,l_2} +
A_1^{\sigma_1}|\sigma_1\rangle _{r_1}\langle 1|1,1\rangle_{r_1,l_2}\\
&= \sum_{\sigma_1} A_0^{\sigma_1} |\sigma_1\rangle |0\rangle_{l_2} + A_1^{\sigma_1}|\sigma_1\rangle |1\rangle_{l_2}
\end{align}
$$



Similarly,

$$
\begin{align}
\mathcal{A}^2 |I_{1,2}\rangle 
&=
\sum_{\sigma_2}\sum_{l_2,r_2}A^{\sigma_2}_{l_2,r_2}|\sigma_2\rangle\langle l_2,r_2|(\sum_{\alpha_1}|\alpha_1,\alpha_1\rangle) \\
&=
\sum_{\sigma_2} (A_{0,0}^{\sigma_2} |\sigma_2\rangle\langle 0,0| + A_{0,1}^{\sigma_2}|\sigma_2\rangle\langle 0,1| + A_{1,0}^{\sigma_2}|\sigma_2\rangle\langle 1,0| + A_{1,1}^{\sigma_2}|\sigma_2\rangle\langle 1,1|)_{l_2,r_2} (|0,0\rangle_{r_1,l_2} + |1,1\rangle_{r_1,l_2}) \\
&=
\sum_{\sigma_2} A_{0,0}^{\sigma_2} |\sigma_2\rangle _{r_2}\langle 0|0\rangle_{r_1} + A_{0,1}^{\sigma_2} |\sigma_2\rangle _{r_2}\langle 0|1\rangle_{r_1} + A_{1,0}^{\sigma_2} |\sigma_2\rangle _{r_2}\langle 1|0\rangle_{r_1}+A_{1,1}^{\sigma_2} |\sigma_2\rangle _{r_2}\langle 1|1\rangle_{r_1} \\
\mathcal{A}^2 |I_{2,3}\rangle 
&=
\sum_{\sigma_2}\sum_{l_2,r_2}A^{\sigma_2}_{l_2,r_2}|\sigma_2\rangle\langle l_2,r_2|(\sum_{\alpha_2}|\alpha_2,\alpha_2\rangle) \\
&=
\sum_{\sigma_2} A_{0,0}^{\sigma_2} |\sigma_2\rangle _{l_2}\langle 0|0\rangle_{l_3} + A_{0,1}^{\sigma_2} |\sigma_2\rangle _{l_2}\langle 0|1\rangle_{l_3} + A_{1,0}^{\sigma_2} |\sigma_2\rangle _{l_2}\langle 1|0\rangle_{l_3}+A_{1,1}^{\sigma_2} |\sigma_2\rangle _{l_2}\langle 1|1\rangle_{l_3}\\
\mathcal{A}^3 |I_{2,3}\rangle
&=
\sum_{\sigma_3}\sum_{l_3}A^{\sigma_3}_{l_3}|\sigma_3\rangle\langle l_3|(\sum_{\alpha_2}|\alpha_2,\alpha_2\rangle)\\
&=
\sum_{\sigma_3} A_0^{\sigma_3} |\sigma_3\rangle _{l_3}\langle 0|0,0\rangle_{r_2,l_3} + A_1^{\sigma_3}|\sigma_3\rangle _{l_3}\langle 1|1,1\rangle_{r_2,l_3} \\
&=
\sum_{\sigma_3} A_0^{\sigma_3} |\sigma_3\rangle |0\rangle_{r_2} + A_1^{\sigma_3}|\sigma_3\rangle |1\rangle_{r_2}
\end{align}
$$



All cross-terms such as $_{r_i}\langle n|m \rangle_{r_i} = _{l_i}\langle n|m\rangle_{l_i} = \delta_{nm}$. All other combinations are equal to zero, i.e. $\mathcal{A}^1|I_{2,3}\rangle =\mathcal{A}^3|I_{1,2}\rangle=0$.

Now we multiply

$$
\begin{equation}
(\mathcal{A}^1\otimes\mathcal{A}^2)(|I_{1,2}\rangle\otimes|I_{2,3}\rangle)
=
\sum_{\sigma_1,\sigma_2} A^{\sigma_1}_0 A^{\sigma_2}_{0,0}|0\rangle_{l_3} + A_0^{\sigma_1}A_{0,1}^{\sigma_2}|1\rangle_{l_3}
\end{equation}
$$


$$
\begin{equation}
|\psi\rangle=
(\bigotimes_i^3 \mathcal{A}^i)(\bigotimes_i^{2} |I_{i,i+1}\rangle)
=
\end{equation}
$$




$$
\begin{equation}
\fbox{Comment: Hmmm. This seems overly impractical... perhaps I've misunderstood something}
\end{equation}
$$


## Bond Dimension

Each $A_{a_i,a_{i+1}}^{\sigma_i}$ above is an $(r_i\times r_{i+1})$ matrix, where $r_i$ is the rank of the Schmidt decomposition at each site $i$. The *bond dimension* of an MPS is defined by

$$D\equiv \max_i r_i$$





# Graphical representation

---

> The following is a summary of the review paper by
>
> [Eisert, J. (2013). Entanglement and tensor network states.](https://arxiv.org/pdf/1308.3318.pdf)

---

We represent mathematical objects in the following way:

<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/scalar.png" height="35"/> Scalar
<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/vector.png" height="35"/> Vector
<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/dualvector.png" height="35"/> Dual Vector
<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/matrix.png" height="35"/> Matrix 

<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/trace.png" height="50"/> Trace
<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/partialtrace.png" height="50"/> Partial Trace
<img src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/scalarproduct.png" height="45"/> Scalar Product


Let $j_i$ be a particle with spin-$1/2$ at position $i$ on a chain with $n$ particles. Then the tensor $c_{j_1,j_2,...,j_n}$ is the collection of complex numbers that tells us in what linear combination a state is in, in terms of its basis vectors:

<img class="center-block"  src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/tensor.png" height="75"/>

$$
\begin{equation}
|\psi\rangle = \sum_{j_1,j_2...j_n}c_{j_1,j_2,...,j_n} |j_1,j_2,...,j_n\rangle
\end{equation}
$$


The Schmidt decomposition allows us to rewrite this tensor in terms of matrices. If we use periodic boundary conditions this looks like

<img class="center-block"  src="https://github.com/DavidAce/Notebooks/raw/master/DMRG/figs/mps.png" height="75"/>


$$
\begin{equation}
|\psi\rangle =
\sum_{a_1,a_2...,a_n}^{r_1,r_2,...,r_n} \text{Tr}(A_{a_1,a_2}^{j_1}A_{a_2,a_3}^{j_2}...A_{a_n,a_1}^{j_n})|j_1,j_2,...,j_n\rangle
\end{equation}
$$


where the trace takes care of the periodic boundary.



