<img src="https://github.com/luuiii/collaborative_algorithm/blob/master/empty_array_nil.png" height="189" width="472"> <br>
## collaborative_algorithm
### Jia & Shuoxin & Song - created @ 2020.11.16 <br>

## **Events** <br>
xiaozu @ beijing, china - 2024.12.01 <br>
[Self-sufficient music #3](https://nubprojectspace.com/programma/self-sufficient-musics-3-li-song-jia-liu-shuoxin-tan.shtml) @ NUB Project Space, Palazzo Fabroni Pistoia, Italy - 2024.10.12 <br>
[CENTRE COURT FESTIVAL 2024](https://ltk4.de/portfolio/centrecourt24/), @ LTK4 cologne - 2024.08.03 <br>
[TOPLAP20](https://archive.org/details/toplap20------) @ karlsruhe - 2024.02.23 <br>
Gemeinde @ cologne - 2023.10.04 <br>
[default #9 x 3345](https://defaultdenhaag.substack.com/p/focus-default-9-x-3345-02102023-with) @ the hague - 2023.10.02 <br>
[default #8](https://defaultdenhaag.substack.com/p/focus-default-8-01102023-with-valerio) @ the hague - 2023.10.01 <br>
iv project space @ brussels - 2023.09.30 <br>
Kiosk Radio @ brussels - 2023.09.30 <br>
ICLC-International Conference on Live Coding @ utrecht - 2023.04.21 <br>
Spanners @ london - 2023.02.26 <br>
Waverly Bar @ edinburgh - 2023.02.25 <br>
La Chunky @ glasgow - 2023.02.24 <br>
[Compassion Through Algorithms, Algorave Tokyo](https://www.forestlimit.com/event-details/compassion-through-algorithms) @ tokyo - 2022.12.27 <br>
[Cafe OTO](https://www.cafeoto.co.uk/events/li-song-ensemble-ecka-mordecai-malvern-brume/) @ london - 2021.12.14 <br>
[HKCR](https://route.notimportant.org) @ Hong Kong - 2021.11.30 <br>
[Ambient Festival](https://ambient-festival.com/ensemble/) @ cologne st.michael - 2021.09.09 <br>
[Der dritte Körper](https://third.notimportant.org) @ cologne st.michael - 2021.08.31 <br>
[algopolis live Ljudmila](https://wiki.ljudmila.org/Algopolis_live) @ ljubljana - 2021.05.14 <br>
escdotdot presents [协作算法音乐表演 | Collaborative Algorithmic Music Performance](https://ava.hkbu.edu.hk/en/events/___) @ HKBU AVA Kai Tak Campus, Hong Kong - 2021.03.14 <br>
[TOPLAP Live Stream](https://transnodal.toplap.org/) - 2021.02.19

## **Release**
[[ _ _ _ ]](https://e---e.bandcamp.com/album/-) <br>
Ensemble [ _  _  _ ] |Song Li(London), Jia Liu(Karlsruhe), Shuoxin Tan(Köln)|<br>
3 Jun 2022, SUPERPANG, Italy <br>
<br>

## **Exhibition**

Der dritte Körper | Media art exhibition <br>
[震荡不消磁 | Sounding Sound Practice in Chinese Mainland and Hong Kong Since the 1990s](https://www.ioam.org.cn/%E9%9C%87%E8%8D%A1%E4%B8%8D%E6%B6%88%E7%A3%81/) <br>
2025.02.22-06.01 @ Inside-Out Art Museum Beijing, China <br>
[International Conference on Live Coding (ICLC)](https://iclc.toplap.org/2023/timetable.html),2023.04.20-23, Utrecht <br>
[Sound & Visual Exhibition](https://www.divfuse.com/index.php/2022/06/26/der-dritte-korper-_-_-_-li-song-jia-liu-shuoxin-tan/)
2022.05 @ DIVFUSE media art gallery, London <br>

[From Other Spaces : [ _ _ _ ] | Sound Exhibition](https://www.divfuse.com/index.php/2022/01/11/from-other-spaces-_-_-_/) <br>
2022.02.25-27 @ DIVFUSE media art gallery, London <br>

## **Scholarships**
Musikfonds, 2021 <br>
Initiative Freie Musik e.V. Köln, 2021 <br>

## **Interview**
[Collaboration and Communication through Network Music](https://defaultdenhaag.substack.com/p/focus-default-9-x-3345-02102023-with) <br>
by Cis De Gendt, 2023.10.02 @ default#9 x 3345, Centrale Bibliotheek Den Haag <br>
<br>
[Articulated Network](https://www.on-cologne.de/en/shuoxin-tan-en/)  <br>
by Shuoxin Tan, 2022.06 @ ON Podcast, Köln <br>
<br>
[Ensemble [ _ _ _ ]](https://www.divfuse.com/index.php/2022/01/11/from-other-spaces-_-_-_/) <br>
by Livia B Garcia, 2022.02.26 @ <em>DIVFUSE</em> media art gallery, London <br>
<br>
[Ensemble [ _ _ _ ]](https://phd.escdotdot.com/escdotdot-presents/ava-bunker-performances/_-_-_/interview-_-_-_-li-song-liu-jia-tan-shuoxin/?fbclid=IwAR0eH9UP5JUJ8Z6rT2vGKeWzA7iAooo6T7hEpxlw9c6qJtPbgJt5rkivuN0) <br>
by Edward Sanderson, 2021.03.14 @ HKBU AVA Kai Tak Campus, Hong Kong
<br>

## Protocol

#### Questions:
- Algorithm in context of Network Music: how could Algorithm be collaborative and distributed?
- If we understand algorithm as function, (how) could they be composed together?
- What ist one's identity in collaborative algorithm?

#### state: <br>
- implemented simple distributed markov chain
- code structure of OSCdefs for multiple individual chains
- simple sound
- state chart window
- new chain \buildUp with a threshold-reaching-retrigger machanism
- optimize the \buildUp sound (additive synthesis)
- added kill and start for chains
- added counter in \state

#### to-do:
- build connection between chains

#### idea-box:
- granular synthesis?
- chain modulate chain?
- \buildUp structure >> the freq-array morphing
- add new chain for dynamic control (2024 to-do?)



#### notes:
sound idea/logic: (notes from 12.7.) <br>
1. the performance is a whole process, this process is about the 3 collaborators building up 1 timbre(Klanggebilde/Teiltongebilde);<br>
2. pointillistic music, so to speak. 3 collaborators share 1 algorithm, but make different sounds, contingency and tacet are very important, must take into consideration. <br>
and so on...

&nbsp; how stockhausen explained group/point &nbsp; <i>[Lecture 1 [PARTE 1/4] Stockhausen Karlheinz - English Lectures (1972)](https://www.youtube.com/watch?v=lYmMXB0e17E)<i> <br>

