#import "@preview/touying:0.4.2": *
#import "@preview/touying-simpl-hkustgz:0.1.0" as hkustgz-theme
#import "@preview/cetz:0.2.2": canvas, draw, tree, plot
#import "graph.typ": show-grid-graph, grid-graph-locations, show-graph, spring-layout, show-udg-graph, udg-graph, random-regular-graph

#let globalvars = state("t", 0)
#let timecounter(minutes) = [
  #globalvars.update(t => t + minutes)
  #place(dx: 100%, dy: 0%, align(right, text(16pt, red)[#context globalvars.get()min]))
]
#let clip(image, top: 0pt, bottom: 0pt, left: 0pt, right: 0pt) = {
  box(clip: true, image, inset: (top: -top, right: -right, left: -left, bottom: -bottom))
}
#set cite(style: "apa")

#let m = hkustgz-theme.register()
#let ket(x) = $|#x angle.r$

// Global information configuration
#let m = (m.methods.info)(
  self: m,
  title: [Quantum evolution training camp],
  subtitle: [],
  author: [Jin-Guo Liu],
  date: datetime.today(),
  institution: [HKUST(GZ) - FUNH - Advanced Materials Thrust],
)

// Extract methods
#let (init, slides) = utils.methods(m)
#show: init

// Extract slide functions
#let (slide, empty-slide, title-slide, outline-slide, new-section-slide, ending-slide) = utils.slides(m)
#show: slides.with()

== Design for change

- #text(red)[Feel] the problem (read the papers)
- #text(blue)[Imagine] the solution (discuss and make a plan through GitHub issues)
- #text(green)[Do] the change (write the code)
- #text(yellow)[Share] the solution (write a blog post - Zhihu)

== To proceed

- Divide into two groups
    - GSE-TDVP
    - BP-Gauge + Simple Update

- Copy the project in folder `RydbergToolkit` to your own GitHub account

==

- Day 1: Feel the problem, read the papers and exchange ideas (4PM-6PM, one hour each group).
- Day 2: Imagine how to solve the problem, make a plan through GitHub issues, share your GitHub issues and projects (11AM-12AM, half hour each group).
- Day 3: Do the change, write a prototype, showcase (4PM-6PM, one hour each group).
- Day 4-X: Implement rest of the plan (4PM-6PM, one hour each group).
- Day X+1: Write a blog post (11AM-12AM, half hour each group).


== Independent set problem
#timecounter(1)

- Independent set: is a set of vertices in a graph, no two of which are adjacent.
- MIS: the maximum independent set

#align(center, box([Finding MIS is NP-complete - unlikely to be solved in time polynomial to the input size @Karp1972.], stroke: black, inset: 10pt))

== Independent set can be reduced to an energy model

MIS is encoded in the _ground state_ of the Hamiltonian:
$
H(bold(n)) = underbrace(- Delta(t) sum_(v in V) n_v, "detuning") + underbrace(sum_((v, w) in E)  infinity n_v n_w, "interaction") + underbrace(Omega(t) sum_(v in V) X_v, "Rabi oscillations") .
$

- $n_v$ is the occupation number of vertex $v$.
  - $n_v = 1$: vertex $v$ is in the independent set
  - $n_v = 0$: otherwise.

The set: ${b, d, e}$ can be represented by $n_b = n_d = n_e = 1$ and $n_a = n_c = 0$.




== King's subgraph at 0.8 filling
#timecounter(1)

#grid(columns: 2, gutter: 20pt,
[#canvas({
  import draw: *
  show-grid-graph(8, 8, filling: 0.8, unitdisk: 1.6)
})
],
[
  - Independent set problem on King's subgraph is NP-hard @Pichler2018, and is implementable on Rydberg atoms arrays @Ebadi2022.
])

== Resources



==
#bibliography("refs.bib")