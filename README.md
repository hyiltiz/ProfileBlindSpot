# Demo

See this for yourself. Close your left eye, and look at the plus sign `+`
below, and slowly move your head closer to the `+` sign. Pay attention to the
money while trying to move your head into the sweet spot distance. Then what
happens?

<details><summary>Spoiler</summary><blockquote>
The money disappears!
</blockquote></details> 

Note: if you are using your phone to look at this, it may barely work since
your phone screen is not wide enough. Simply replicate it on a piece of paper,
or try viewing your phone in horizontal mode.

```




    +                                        $




```

Where did the money go!? How about the following?

```


                                  $$$$$$$$$$$$$$$$$$$$$$
                                  $$$$$$$$$$$ $$$$$$$$$$
    +                             $$$$$$$$$$   $$$$$$$$$
                                  $$$$$$$$$$$ $$$$$$$$$$
                                  $$$$$$$$$$$$$$$$$$$$$$




```
How come the logo on the flag disappeared? 


# Explanation

The optic nerve (that transmits visual signal) goes right through the retina (the "camera sensor", so to speak).
Thus, we are effectively blind there. Inside the eye, these optic nerves are
closer to the nose. As a result, your right eye is blind slightly to your
right, regardless of what you are looking at. If you stretch your hands forward
next to each other with your palms facing down and look at your left pinky, the
blind spot of your right eye roughly corresponds to your right pinky direction.
See the model below as illustrated from behind the retina of the right eye.

!(Blind spot on the retina)[https://raw.githubusercontent.com/hyiltiz/ProfileBlindSpot/main/BlindSpotEyeball.gif]

As a result of the missing sensors in this region, you'll be blind within
corresponding region *in the world* (called the visual field), as illustrated
below for the right eye:

!(Blind spot in the world)[https://raw.githubusercontent.com/hyiltiz/ProfileBlindSpot/main/BlindSpotVisualField.png]

With this game, you can actually trace the out how *your very own* optic nerves
block your vision. Your blind spots were always there; it is just our
perceptual system was kind/smart enough to "fill in" the missing information
based on the surroundings.


# How to use
Run the program `ProfileBlindSpot.m` using `Octave` or `Matlab`. You'll need to
[install `Psychtoolbox`](http://psychtoolbox.org/download.html) as a
dependency. Follow the game
instructions. Once finished, the sub-function `analyzeBlindSpot` automatically
traces the blind spot boundary and its retinal map on a spherical eye model.

The game looks like this.
!(Game screen)[https://raw.githubusercontent.com/hyiltiz/ProfileBlindSpot/main/raw.png]

Note that the boundaries are created with the `boundary(x,y)` function that
traces the boundary polygon given the point coordinate vectors. This function
is included in Matlab since R2014, but not in Octave by default.

