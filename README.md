# Fitting the lifetimes of strange particles by reconstructing decays from proton-antiproton collisions at the CDF experiment

Some code from a computing project I did in 2nd year. Some of it is mine and some is by the University of Oxford.
Most of it is just a bunch of classes needed to do the data analysis + event reconstruction but I also added some code I used to make some of the graphs I used in my final project writeup.

The data file cdf.dat contains all the CDF data I used for this project.

The classes folder has a bunch of classes made for taking the data from the CDF file given with the project (CdfDataFile) for each event (CdfEvent) and recording track parameters (CdfTrack) to then be plotted as helical paths (Helix).
Using these paths we find intersections where a particle has decayed and we can use the information from its decay products to find out lots of properties about the original particle, including mass and lifetime (Vertex).
Using the analyses classes K0SAnalysis and LambdaAnalysis we can find probable K-short mesons and Lambda baryons and plot their recorded masses and lifetimes using the Histogram class.
In my final writeup the masses agreed with the world average very well.
The Loop class is just used so you can loop over all events in the CDF data file and the Analysis class is an abstract class which K0SAnalysis and LambdaAnalysis are subclasses of.

Unrelated to my project, I also created a class named EventDisplay.
This class takes the data from an event and plots the detected helical tracks in 2/3 dimensions.
Given certain cuts to the momentum or impact parameter you can highlight or choose not to display the tracks that don't make the cut (I'll add some plots and the code I used to make them when I can).

The tests folder just contains some tests I used to plot helical tracks or plots of the mass/lifetime of the particles I was looking for (I'll also add these plots when I can).
I also performed a chi-squared fit of the lifetimes to an exponential distribution to find an estimate of the mean lifetime and the plot of the chi-squared value can be found in CO03_tests4.
My estimated mean lifetimes were around two standard deviations away from the expected results, which isn't great, but showed I was on the right track in terms of making the right cuts.
I also really need to add comments to my tests, I was making them on the fly so please forgive me for the terrible practice if you don't have any idea what I'm doing.

I have added comments if the code is not made by me but just to reiterate, the code **I** made is listed below:
* EventDisplay.m
* Helix.m
* K0SAnalysis.m
* LambdaAnalysis.m
* Vertex.m
* All tests

Everything else is credited to the University of Oxford.
