# mental-navigation-meg
Mental Navigation for MEG 

# TODO
## Jan 27 
0. Add a smaller window to redcuce field of view to ( 3 images ) replace with gradient 
0.1. Add a square at the center, this helps participants to be accurate.( low priority ; implement and see )
0.2. Record the file for each run; also for edf 
0.3 Try increase ILM distance

1. Select appropriate images Change images so category is cat/dog etc
 https://chatgpt.com/c/69789466-95d8-832f-be19-5c21e6b5e0cc ; wordfreq packages 
2. Add image presentation in for decoding at end of experiment [One image at a time ; centrally; duration 500ms; review papers;marius peelen (decoding meg)]
4. Cue at the start of each block, not in every trial . DONE. (FAST or slow text)
5. Add in one or two cycles while text is displayed  
1 loop
add more information in speed
(blank screen (for some sec) then speed cue) ( fixation cross and change color for movement ) 
6. At the start of each trial, show first two images [TBD today]
7. Add in resting state data collection between runs [During break stop eye tracking or meg and collect data??] 

8. Free navigation at start [?? is this where participants are allowed to press a button to move left or right???]
  make a different script 
run only on first day to familiarize the environment
(duration : 4 minutes (max) ; add stop key  )

# cedrus - look in to giuliano's code for ptb functions? (  )

9. Questionnaire, vividness validated question ( find validated questionnaires ; common psychological questions - chatgpt)

10. How to test meg ttls? is there a dummy mode? (A overview of meg code?)
 refer to photo diode code : gf5_present_letters  (search photo diode) 
use this for relevant events

# prioritize stimuli : 
share screenshots


1. Selection of Stimuli 
    1. Icons
    2. Realistic images with color [ replace background with solid background]
    3. Look for datasets that use animals with solid bg 
    Animals : Dog Cat Pig Rat Cow Donkey

2. Replace the speed cues as : FAST or SLOW . DONE .
3. Add instructions on the speed cue  [ added placeholder]
4. Replace do with fixation corss and change color of the fixation cross when movement starts . DONE .
5. Save data file at each run ( behavior , eye and meg(manual) ) . DONE .
6. Make a seperate script for free navigation. Free navigation is used for training before the actual experiment. DONE .
7. Find common psychological questions and validated questionnaires
8. Add contrast gradient to images such that only three images are visible at a time
9. Add a square at the center, this may participants to get an accurate feedback [to be discussed]
10. Add a input at start to select InterLandmarkDistance ( try different ILDs). ( we can try this from setup_exp_env and test in meetings)
11. Test data collection




