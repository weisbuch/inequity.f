globals
[
choi2  ;; chosen move of the neighbor
choi   ;; chosen move of the agent
]


patches-own [
index  ;; index for the payoff matrix
listJ  ;; the vector of preference coefficients J
magie  ;; intermediate vector of preference coefficients J
profit  ;; actual payoff according to agent and neighbor choices
listreward   ;; payoff matrix
vj  ;; intermediate preference coefficients to be updated
]

to init ;; set inital preference coefficients J
ca
ask patches [ if (Initial_conditions = "444")
  [set listJ (list (random-float 4) (random-float 4) (random-float 4 ))]
if (Initial_conditions = "414")
  [set listJ (list (random-float 4) (random-float 1) (random-float 4 ))]
if (Initial_conditions = "141")
  [set listJ (list (random-float 1) (random-float 4) (random-float 1 ))]
    ;; payoff matrix
 set listreward  (list (0.5 - lambda) (0.5 - lambda) (0.5 - lambda) 0.5 0.5 0 (0.5 + lambda) 0 0)
  ]
  reset-ticks
end

to go
  repeat 1000 [
    ask one-of patches [ test ]
  ]
 tick
end

to test
  let pp one-of patches ;; choosing a neighbor to play with       !
  if (connections = "lattice_4n") ;;                              !
  [set pp one-of neighbors4]   ;;                                 !
  if (connections = "lattice_8n")  ;;                             !
  [set pp one-of neighbors]      ;;                               !
  ask pp [set choi2 bma (listJ) ;; neighbor plays choi2 according to bma
  set magie maj (listJ) ;; decrease neighbor' J's by factor gam
  ]
  set choi bma (listJ) ;; agent plays choi according to bma
  set magie maj (listJ) ;; decrease agent's all J by factor gam
  set index 3 * choi + choi2 ;; index of payoff matrix according to choices
  set profit item index listreward  ;; actual payoff
  set vj item choi magie ;; previous J value
  set magie replace-item choi magie (vj + profit) ;; adding actual profit to previous J value
  set listJ magie ;; final update of J
  ask pp [ set index 3 * choi2 + choi ;; same operations for neighbor !
  set profit item index listreward ;;                                 !
  set vj item choi2 magie ;;                                          !
  set magie replace-item choi2 magie (vj + profit);;                  !
  set listJ magie ;;                                                  !
  recolor (listJ)] ;;                                                 !
  recolor (listJ)
end

to-report bma [J]  ;; Boltzmann choice of action
  let listPZ map [[ i ] -> exp (beta * i) ] J ;; Boltzmann exponential
  let Z sum listPZ  ;; Boltzmann denominator
  let P map [[i] -> i / Z] listPZ  ;; Boltzmann probabilities
  let rf random-float 1
  ifelse rf < item 0 P  ;;random sampling according to Boltzmann probabilities
     [report 0]  ;; choose L
     [ ifelse rf < ( item 1 P + item 0 P)
          [report 1]  ;; choose M
       	  [report 2]  ;; choose H
    ]
end

to-report maj [J]  ; decreasing vector J by factor gam
   let mJ map [ [i] -> gam * i ] J ;;
	 report mJ
end

to recolor [J]  ;;  coloring cells according to J vector
  let Z sum J
  let col map [[i] -> i / Z] J
  let g precision (item 0 col * 255) 0  ;; green J0 preference for playing L
  let b precision (item 1 col * 255) 0  ;;  blue J1 preference for playing M
  let r precision (item 2 col * 255) 0  ;;  red J2 preference for playing H
  let listcol (list r g b)
  set pcolor ( listcol )
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
10
10
73
43
NIL
init
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
110
185
143
beta
beta
0
60
50.0
0.1
1
NIL
HORIZONTAL

SLIDER
14
155
186
188
gam
gam
0
1
0.5
0.05
1
NIL
HORIZONTAL

BUTTON
97
19
187
52
go once
go\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
13
63
76
96
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
664
11
1146
445
population
time
number
0.0
1000.0
0.0
100.0
true
true
"set-plot-y-range 0 1000" ""
PENS
"L" 1.0 0 -13840069 true "" "plot count patches with [pcolor = [0 255 0]] "
"M" 1.0 0 -13791810 true "" "plot count patches with [pcolor = [0 0 255]] "
"H" 1.0 0 -2674135 true "" "plot count patches with [pcolor  = [255 0 0 ]] "

CHOOSER
21
245
159
290
connections
connections
"lattice_4n" "lattice_8n" "mean field"
0

SLIDER
16
198
188
231
lambda
lambda
0
0.5
0.2
0.05
1
NIL
HORIZONTAL

CHOOSER
24
309
138
354
Initial_Conditions
Initial_Conditions
"444" "414" "141"
0

@#$#@#$#@
WHAT IS IT?

The model describes the dynamics of the bargaining game proposed by Nash
in 1950. During one session of the game, each agent
can, independently of his opponent, request one among three demands:
L(ow) demand 30 perc. of a pie, M(edium) 50 perc. and H(igh) 70 perc.
As a result, the two agents get at the end of the session
what they demanded when the sum of both demands is less or equal
to the 100 perc. total; otherwise they get nothing.
In the course of repeated games with neighbours, agents
learn the expected benefit they can obtain and built preference coefficients
J to choose their next moves.

HOW IT WORKS

Except for the mean field choice, each agent occupies the cell of a 33x33 lattice.
Randomly chosen agents play the bargaining game with one of their neighbours.
In the course of repeated games agents
learn the expected benefit they can obtain by building preference coefficients
J for each possible move by computing a moving average of the benefits obtained during previous sessions. 
They choose their next move according to Boltzmann probabilities
of expected benefits. 

HOW TO USE IT

The init button establishes the inital conditions randomly according to the chooser.
(with 444 all moves can be equally choosen,
414 favours choices H and L with respect to M,
141 favours choices M with respect to H and L).

The 3 sliders allow to set the parameters of the model: 
- larger beta favours strict ‘greedy’ choices such that agents exploit the information
they previously gathered; lower beta values give random choices
and favours exploration;
- gam is a memory parameter of previous choices, higher values close to 1
imply long term memory.
- lambda is a greed parameter: large values make bigger differences in the alloted shares of the pie; 
lambda=0.2 gives the original shares proposed by Nash (0.3, 0.5, 0.7).
It might be easier to initially maintain constant the values gam=0.9 and lambda=0.2
to practice with changing beta from 0.0 to 3. You may later check the influence
of the two other parameters.

The connections button allows to set the choice of neighbourhood:
- with the mean field choice any pair of agents can play the game;
- with lattice_4n an agent can only play with his 4 neighbours N, S, E, W.
- with lattice_8n an agent can only play with his 8 neighbours.

-The go once and go buttons allow the games to proceed until
stopped when go is pressed again. 

  The left figure represents the preference coefficients of agents
on the lattice according to a colour code: green codes for L,
blue for M and red for H. 

The right plot display the evolutions of agent populations
with pure preferences for H, M or L choices. The time unit is the
the average time between two games per agents.

THINGS TO NOTICE

The spatio-temporal dynamics depends upon parameter and initial
conditions. Low beta values result in disordered regimes such that
agents' choices are random and incoherent. The observed colors on
the lattice plot are composite since all preference coefficients are non-zero. 
 Increasing beta from 0 one obtains
ordered regimes such that agents' choices end-up being fix and
coordinated in either an equity regime (the blue cells on the configuration diagram) 
or in a class systems such that some higher class agents (the red cells)
exploit their neighbours (the green cells) by requesting and obtaining high share H. 

THINGS TO TRY

What are the critical values of beta, gam and lambda coefficients
separating the different regimes? What is the influence of the connections
button on the spatial display?
 Does the dynamics changes with the size of the lattice?
(It can be adjusted by changing max-pxcor and  max-pycor
 when one edits the lattice display).

EXTENDING THE MODEL

- Extend the choice of possible initial conditions.
- Check for resp. revolutions or resp. conquests when starting from homogeneous islands
of resp. M agents among a sea of H/L players or from islands of H/L agents among M agents. 
What should be added to the model to display conquests?
- You might try to check the influence of other connection structures,
scale free networks for instance using netlogo library.  
- What about layered networks and n-level hierarchies? 

RELATED MODELS

- Axtell, R. L., Epstein, J. M. & Young, H. P. (2001). The emergence of classes in a multiagent bargaining model. Social dynamics, (pp. 191-211),
They start from Nash bargaining game but with different learning and choice processes. 

- Axtell etal choices are used by Poza, D. J., Santos, J. I., Galán, J. M. & López-Paredes, A. (2011). 
Mesoscopic effects in an agent-based bargaining model in regular lattices. PLoS One, 6(3), e17661  
and Santos, J. I., Poza, D. J., Galán, J. M. & López-Paredes, A. (2012). Evolution of equity norms in small-world networks. Discrete Dynamics in Nature and Society, 2012.
Both models use social networks. 

- The model using this netlogo program is fully described in
Weisbuch, G. (2018): Persistence of discrimination: Revisiting Axtell, Epstein and Young. Physica A: 
Statistical Mechanics and its Applications, 492(Supplement C), pp. 39-49.
doi: https://doi.org/10.1016/j.physa.2017.09.053
URL http://dx.doi.org/https://doi.org/10.1016/j.physa.2017.09.053
for the mean field version.

- The lattice version is submitted for publication
in JASSS as “Lattice dynamics of inequity”. 

CREDITS AND REFERENCES

- A former version of Nash bargaining game based on evolutionary game theory
is part of netlogo Models Library: Social Science/(unverified)/Divide The Cake

- https://www.openabm.org/model/5425/version/1/view is a netlogo 5 version
of Axtell etal and Poza etal models.

- The present program runs with netlogo 6. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
