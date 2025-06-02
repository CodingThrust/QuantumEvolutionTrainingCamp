#import "@preview/touying:0.4.2": *
#import "@preview/touying-simpl-hkustgz:0.1.0" as hkustgz-theme
#import "@preview/cetz:0.2.2": canvas, draw, tree, plot, decorations
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
  subtitle: [Simulation of Rydberg atoms arrays],
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

== What is a Rydberg atom?
#timecounter(1)
Any element type, with the outermost electron in a *very high* energy level.
#figure(canvas({
    import draw: *
    let s(it) = text(16pt, it)

    circle((0, 1), radius: 0.1, fill: black, stroke: none, name: "pos")
    circle((0, 1), radius: 0.3, fill: none, stroke: black, name: "ground")
    circle((0, 1), radius: 1.6, fill: none, stroke: black, name: "excited")
    line((anchor: 30deg, name: "ground"), (anchor: 30deg, name: "excited"), mark: (end: "straight"), name: "line")
    circle((anchor: 30deg, name: "ground"), radius: 0.1, name: "e", fill: blue, stroke: none)
    content((rel: (0, 0.4), to: "e"), s[$e^-$])
    decorations.wave(
      line((rel: (-0.5, 1.5), to: "line.mid"), (rel: (-0.1, 0.3), to: "line.mid")),
      amplitude: 0.2,
      segment-length: 0.2,
      color: black,
    )
    content((0, 0.5), s[5s])
    content((2, 1.5), s[70s])
    content((1.5, 2.8), s[Laser])

    set-origin((5, 0))
    line((0, 0), (1, 0), stroke: black, thickness: 1pt)
    content((1.8, 0), s[$ket(5s)$])
    line((0, 2), (1, 2), stroke: black, thickness: 1pt)
    content((4.2, 2), s[$ket(70s)$ (Rydberg state $ket(r)$)])
    line((0.5, 0), (0.5, 2), stroke: black, mark:(end: "straight"))
    content((0.9, 1), s[$Omega$])
}))

e.g. For #super("87")Rb atoms, the 5s state is the ground state, and a typical excited state is $70s$.

==
#timecounter(1)

#figure(canvas({
  import draw: *
  let s(it) = text(14pt, it)
  content((0, 0), image("images/scaling.png", width: 500pt))
  rect((-9, -0.4), (7, 0.1), stroke: red, thickness: 1pt)
  rect((-9, -1.5), (7, -1), stroke: red, thickness: 1pt)
  rect((-9, -3.1), (7, -2.6), stroke: red, thickness: 1pt)

  let x = 9
  let y = -0.4
  let dx = 0.6
  content((x + dx, y + 1.3), s[Polarization])
  circle((x, y), radius: 0.1, fill: black, stroke: none, name: "pos")
  circle((x + dx, y), radius: (1 + dx, 1), stroke: black, fill: none)
  circle((x + dx, y), radius: 0.1, fill: blue, stroke: none, name: "neg")
  content((rel: (0, -0.3), to: "pos"), s[$n^+$])
  content((rel: (0, -0.3), to: "neg"), s[$e^-$])
  line((x - 1, y - 1.5), (x + 1 + 2 * dx, y - 1.5), mark: (start: "straight"))
  content((x + dx, y - 2), s[$E$])
}))

== Trap Rydberg atoms
#timecounter(1)

With optical traps (Note: typical wave length of light is 500nm)

#figure(canvas({
    import draw: *
    let s(it) = text(16pt, it)
    content((0, 0), image("images/trap.png", width: 350pt))
    set-origin((12, 0))
    hobby((-2, 0), (-1, -0.2), (-0.5, -1), (0, -2), (0.5, -1), (1, -0.2), (2, 0), close: false, smooth: 6pt, stroke: (paint: black, thickness: 1pt))
    circle((0.0, -1.8), fill: black, stroke: none, radius: 0.1)
    content((0, 1), s[Atomic temperature: $~mu K$])
    content((0, -2.3), s[Single optical trap])
}))

A tweezer array with 6100 highly coherent atomic qubits @Manetsch2024

==
#timecounter(1)

#figure(canvas({
  import draw: *
  let s(it) = text(14pt, it)
  content((0, 0), image("images/scaling.png", width: 500pt))
  rect((-9, -3.7), (7, -3.2), stroke: red, thickness: 1pt)

  let x = 9
  let y = -0.4
  let dx = 0.6
  content((x + dx, y + 1.3), s[Polarization])
  circle((x, y), radius: 0.1, fill: black, stroke: none, name: "pos")
  circle((x + dx, y), radius: (1 + dx, 1), stroke: black, fill: none)
  circle((x + dx, y), radius: 0.1, fill: blue, stroke: none, name: "neg")
  content((rel: (0, -0.3), to: "pos"), s[$n^+$])
  content((rel: (0, -0.3), to: "neg"), s[$e^-$])
  line((x - 1, y - 1.5), (x + 1 + 2 * dx, y - 1.5), mark: (start: "straight"))
  content((x + dx, y - 2), s[$E$])
}))


== Interaction between Rydberg atoms
#timecounter(1)
#grid(columns: 2, gutter: 20pt, [#figure(image("images/rydberg-interact.png", width: 350pt), caption: text(18pt)[Two-body interaction strength for ground-state Rb atoms, Rb atoms excited to the 100s level, and ions. @Saffman2010], numbering: none)], [
#figure(canvas({
  import draw: *
  for (x, y, name) in ((-2, 0, "1"), (2, 0, "2")){
    circle((x, y), radius:0.6, fill: none, stroke: (dash: "dashed"), name: name)
    circle((x, y - 0.3), radius: 0.1, fill: black, stroke: none, name: "a")
    circle((x, y + 0.3), radius: 0.1, fill: blue, stroke: none, name: "b")
    line("a", "b", mark: (start: "straight"))
  }
  for (a, b) in (("1", "2"),){
    decorations.wave(line(a, b), amplitude: 0.2)
  }
  content((0, -1), text(16pt)[$V_("Ryd") = C_6\/R^6$])
}))
Key information:
- Close: very strong interaction
- Distant away: nearly non-interacting
])

== Using Rydberg atoms as qubits
#timecounter(1)

Through Hamiltonian dynamics, controlled by lasers.

#figure(canvas({
    import draw: *
    let s(it) = text(16pt, it)
    line((0, 0), (1, 0), stroke: black, thickness: 1pt)
    content((1.7, 0), s[$ket(g)$])
    line((0, 2), (1, 2), stroke: black, thickness: 1pt)
    content((1.7, 2), s[$ket(r)$])
    line((0.5, 0), (0.5, 2), stroke: black, mark:(start: "straight", end: "straight"))
    content((-0.4, 1), s[$Omega^"r"$])
    content((0.5, -1), s[Simulator])

    set-origin((8, 0))
    let dy = 0.3
    line((0, -dy), (1, -dy), stroke: black, thickness: 1pt)
    content((1.7, -dy), s[$ket(0)$])
    content((1.7, 0.4), s[$ket(1)$])
    line((0, 2), (1, 2), stroke: black, thickness: 1pt)
    content((1.7, 2), s[$ket(r)$])
    line((0, dy), (1, dy), stroke: black, thickness: 1pt)
    content((1.7, 2), s[$ket(r)$])
    line((0.5, dy), (0.5, 2), stroke: black, mark:(start: "straight", end: "straight"))
    line((0.5, dy), (0.5, -dy), stroke: black, mark:(start: "straight", end: "straight"))
    content((6, 0.0), s[Long coherence time ($>> 1"ms"$)])
    content((-0.4, 1), s[$Omega^"r"$])
    content((-0.4, 0), s[$Omega^"hf"$])
    content((0.5, -1), s[Digital (fine structure)])
}))

- _Hyperfine structure_: the energy level split caused by the nuclear spin - electron spin coupling.

== Maximum independent set problem
#timecounter(1)

- Independent set: is a set of vertices in a graph, no two of which are adjacent.
- MIS: the maximum independent set

#align(center, box([Finding MIS is NP-complete - unlikely to be solved in time polynomial to the input size @Karp1972.], stroke: black, inset: 10pt))

#let formin() = {
  import draw: *
  let s = 2
  let dy = 3.0
  let la = (-s, 0)
  let lb = (0, s)
  let lc = (0, 0)
  let ld = (s, 0)
  let le = (s, s)
 
  for (l, n, color) in ((la, "a", red), (lb, "b", black), (lc, "c", red), (ld, "d", black), (le, "e", red)){
    circle((l.at(0), l.at(1)-s/2), radius:0.4, name: n, stroke: color)
    content((l.at(0), l.at(1)-s/2), text(14pt)[$#n$])
  }
  for (a, b) in (("a", "b"), ("b", "c"), ("c", "d"), ("d", "e"), ("b", "d")){
    line(a, b)
  }
}


#grid([
#pad(canvas({
  import draw: *
  formin()
  content((0.5, -2), [$G = (V, E)$])
}), x:20pt)
],
[
  - 0 for not in the set
  - 1 for in the set
],[
#figure(image("images/nature.jpg", width:120pt))
],[*The nature of computation*\ By: Cristopher Moore and Stephan Mertens],
columns: 4, gutter: 30pt
)



// == Hierachy of hardness
// #timecounter(1)

// #let pointer(start, end, angle: 45deg) = {
//   import draw: *
//   draw.get-ctx(ctx => {
//     let (ctx, va) = coordinate.resolve(ctx, start)
//     let (ctx, vb) = coordinate.resolve(ctx, end)
//     let dy = vb.at(1) - va.at(1)
//     let dx = dy / calc.tan(angle)
//     let cx = va.at(0) + dx
//     let cy = vb.at(1)
//     line(start, (cx, cy))
//     line((cx, cy), end)
//   })
// }

// #grid(canvas(length: 0.8cm, {
//   import draw: *
//   let s(it) = text(16pt, it)
//   circle((0, 0), radius: (6, 4), stroke: (paint: black, thickness: 1pt))
//   circle((3, 0), radius: (3, 2), stroke: (paint: black, thickness: 1pt))
//   hobby((-1, 1), (-2, 3), (-5, 3), (-7, 0), (-5, -3), (-2, -3), (-1, -1), close: true, smooth: 10pt, stroke: (paint: black, thickness: 1pt), fill: blue.transparentize(50%))
//   circle((-4, 0), radius: (2, 2), stroke: (paint: black, thickness: 1pt), fill: yellow.transparentize(20%))

//   content((1, 3), s[NP])
//   content((-4, 0), s[P])
//   content((-2, 2), s[BQP])
//   content((3, 0), s[NP-complete])
//   for (i, j, name) in ((-2, -1.5, "B"), (5.5, 0, "C"), (-6.5, 0, "S")) {
//     circle((i, j), radius:0.2, fill: black, name:name)
//   }
//   content((-7, -4), box(s[Factoring], inset: 5pt), name: "Factoring")
//   content((-8.5, 0), box(s[Quantum \ Sampling], inset: 5pt), name: "Sampling")
//   content((-3, 5), box(s[Maximum independent set], inset: 5pt), name: "Spinglass")
//   //content((-7, 5), box(s[Graph isomorphism], inset: 5pt), name: "GI")
//   set-style(stroke: (paint: black, thickness: 1pt))
//   pointer("B", "Factoring", angle: 45deg)
//   pointer("C", "Spinglass", angle: -65deg)
//   //pointer("G", "GI", angle: -65deg)
// }),
// [
// - *NP* (nondeterministic polynomial): Decision problem, polynomial time verifiable
//   - $1 + 1$
//   - Factoring a large number: $? times ? = z$.
//   - Spin glass, MIS
//   - Proving
// - *P:* Polynomial time solvable
// - *NP-complete:* The hardest problems in NP
// - *BQP:* Polynomial time solvable on a quantum computer
// ],
// columns: 2, gutter: 20pt)

== Problem reduction
#timecounter(1)

#canvas(length: 0.8cm, {
  import draw: *
  let s(it) = text(16pt, it)
  let desc(loc, title) = {
    content(loc, [#text(blue, [*#title*])])
  }
  circle((0, 0), radius: (8, 4))
  circle((4, 0), radius: (4, 2), fill:aqua)
  desc((-4, 0), s[NP])
  desc((5, 0.8), s[NP-complete])
  for (i, j, name) in ((0, 2, "A"), (0.6, 0, "B"), (-2, -1, "C"), (3, -1.5, "D"), (4, -0.5, "E")) {
    circle((i, j), radius:0.2, fill: black, name:name)
  }
  for (a, b) in (("A", "B"), ("C", "B")) {
    line(a, b, mark:(end:"straight"), stroke:(thickness:2pt, paint:black))
  }
  for (a, b) in (("D", "B"), ("E", "B"), ("D", "E")) {
    line(a, b, mark:(end:"straight", start: "straight"), stroke:(thickness:2pt, paint:black))
  }
  line((11, 1), (13, 1), mark:(end:"straight"), stroke:(thickness:2pt, paint:black))
  content((16, -1), block(s[A is _reducible_ to B: Map problem A to problem B, the solution of B can be mapped to a solution of A.], width:250pt))
})

Maximum independent set problem (NP-complete) $arrow.r.double$ Rydberg atoms ground state finding

#figure(box(stroke: black, inset: 10pt)[Can we speed up NP-complete problem solving with a quantum device?])


== Blockade effect
#timecounter(1)

Two atoms close to each other can not be both excited to the Rydberg state

#figure(canvas({
    import draw: *
    let s(it) = text(16pt, it)
    line((0, 0), (1, 0), stroke: black, thickness: 1pt, name: "g")
    content((1.7, 0), s[$ket(g)$])
    line((0, 2), (1, 2), stroke: black, thickness: 1pt, name: "r")
    content((1.7, 2), s[$ket(r)$])
    circle("r.mid", radius: 0.1, fill: red, stroke: none)

    let dx = 5.0
    line((dx, 0), (dx + 1, 0), stroke: black, thickness: 1pt, name: "g2")
    content((dx + 1.7, 0), s[$ket(g)$])
    line((dx, 2), (dx + 1, 2), stroke: black, thickness: 1pt, name: "r2")
    content((dx + 1.7, 2), s[$ket(r)$])
    line((dx + 0.5, 0), (dx + 0.5, 2), stroke: black, mark:(end: "straight"), name: "excit")
    circle("g2.mid", radius: 0.1, fill: blue, stroke: none)
    content("excit.mid", text(red)[$times$])
    content((rel: (1.5, 0), to: "excit.mid"), text(red, 16pt)[Forbidden])

    content((dx / 2 + 1, -1.5), s[Physical systems do not favor high energy states])
}))

// == Blockade v.s. phase of matter
// #timecounter(1)

// #figure(image("images/phase.png", width: 550pt))


== Independent set can be reduced to an energy model
#timecounter(1)

MIS is encoded in the _ground state_ of an energy model:
$
H(bold(n)) = underbrace(- sum_(v in V) n_v, "weights") + underbrace(sum_((v, w) in E)  infinity n_v n_w, "independence constraints").
$

- $n_v$ is the occupation number of vertex $v$.
  - $n_v = 1$: vertex $v$ is in the independent set
  - $n_v = 0$: otherwise.

The set: ${b, d, e}$ can be represented by $n_b = n_d = n_e = 1$ and $n_a = n_c = 0$.

== Solving MIS problem on Rydberg atoms array
#timecounter(1)

#figure(image("images/rydberg.png"))

Quantum optimization of maximum independent set using Rydberg atom arrays @Ebadi2022


// == Rydberg Hamiltonian
// #timecounter(1)

// $
// H = underbrace(sum_i Omega_i(t)/2 X_i, "Rabi term") - underbrace(sum_i Delta_i n_i, "Detuning")
// + underbrace(sum_(i < j) V_(i j) n_i n_j, "Rydberg-Rydberg interaction")
// $

// - $Omega_i arrow.r 0$
// - $V_(i j) arrow.r cases(infinity "if atoms i and j are close", 0 "otherwise")$

== How to find the ground state? Quantum annealing
#timecounter(1)

#figure(box(stroke: black, inset: 10pt)[By quantum annealing: $H(t) = (1-lambda t) H_0 + lambda t H_1$])

- The initial state is the ground state of $H_0$.
- The energy gap between the ground state and the first excited state is not closed during the annealing process.
- The $lambda$ is small enough (adiabatic condition).

$arrow.double$ The final state is the ground state of $H_1$.

#figure(box(stroke: black, inset: 10pt)[*Adiabatic theorem*: a quantum state remains in the ground state if the Hamiltonian is changed slowly.])

==
#timecounter(1)

$
H(t) = - Delta(t) sum_i n_i + infinity sum_(i < j) n_i n_j + Omega(t) sum_i X_i
$

- $t = 0$: $Delta < 0$ the ground state is easy to find, $n_i = 0$
- $t = 1$: $Delta > 0$, the ground state is hard to find.

The extra $Omega(t)$ terms is to avoid level crossing.

== Control pulses
#timecounter(1)

#figure(canvas({
  import plot: *
  import draw: *
  let s(it) = text(16pt, it)
  plot(
    size: (8,4),
    x-ticks: ((0, "0"), (1, "1")),
    y-tick-step: 10,
    x-label: [$t$],
    y-label: [Strength],
    name: "plot",
    {
      add(((0, 0), (0.5, 0), (1, 1), (5, 1), (5.5, 0), (6, 0)), domain: (0, 1), label: [$Omega$])
      add(((0, -0.2), (6, 1.5)), domain: (0, 1), label: [$Delta$])
    }
  )
}))

- $Omega(t)$: Rabi frequency (blue) - decreases from 1 to 0
- $Delta(t)$: Detuning (red) - increases from -0.5 to 0.5
- Initial state: $|0⟩$ (ground state)
- Final state: Ground state of the target Hamiltonian


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


== Design for change

- #text(red)[Feel] the problem
  - Read the papers
  - 5W2H rule: What, Why, When, Where, Who, How and How much?
- #text(blue)[Imagine] the solution
  - Discuss
  - Make a plan through GitHub issues and GitHub projects
- #text(green)[Do] the change
  - Write the code through GitHub issues
  - Follow the agile development process, and write a prototype ASAP
- #text(yellow)[Share] the solution
  - Final presentation
  - Write a blog post - Zhihu or your own blog

== To proceed

- Divide into two groups, decide a group leader
    - GSE-TDVP
    - BP-Gauge + Simple Update

- Copy the project in folder `RydbergToolkit` to `CodingThrust/XXX`.

==

- Day 1: Feel the problem, read the papers and exchange ideas (4PM-6PM, one hour each group).
- Day 2: Imagine how to solve the problem, make a plan through GitHub issues, share your GitHub issues and projects (11AM-12AM, half hour each group).
- Day 3: Do the change, write a prototype, showcase (4PM-6PM, one hour each group).
- Day 4-X: Implement rest of the plan.
- Day X+1: Group presentation, and write a blog post.

== How to ask questions

- _On the same page_: a group of people are working on the same problem, and their understanding of the problem is similar.
- If not, _go through > pop up questions_: Can I take your 1 hour to *go through* a recent paper that is crucial for the project? (mindset: any individual has a very *limited knowledge* of the project. Before sharing any idea, he needs to "feel" the problem.)

== Extra Resources

- Project repo: https://github.com/CodingThrust/QuantumEvolutionTrainingCamp

=== Huanhai Zhou's recommendations

- 推荐这个讲TDVP的视频，是我唯一一个能听明白的[破涕为笑]：https://cast.itunes.uni-muenchen.de/clips/tdCyLOqHgq/vod/high_quality.mp4

- 是一系列lecture里的一部分，notes也写得挺初学者友好：https://www2.physik.uni-muenchen.de/lehre/vorlesungen/sose_20/tensor_networks_20/skript/index.html

- https://edoc.ub.uni-muenchen.de/35102/1/Grundner_Martin.pdf#page34 这个thesis对TDVP GSE的介绍比原文好读
==
#bibliography("refs.bib")