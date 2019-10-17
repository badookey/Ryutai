# Ryutai

Ryutai is an interactive experience focusing on the meditative qualities of flowing water. 
This was initally created for the subject 'Interactive Media' at the University of Technology Sydney. Use your hands to play with a liquid-like substance and pop bubbles to make gong noises.
![Ryutai Screenshot](screenshots/Ryutai.png?raw=true "Ryutai")

# Setup
The following hardware and software is required in order to run Ryutai.

Leap Motion Controller (https://www.leapmotion.com)

Processing 3.3.6 (https://www.leapmotion.com) with libraries:
- Beads
- PixelFlow
- Leap Motion library for Processing

*All libraries available within Processing's internal library viewer.*

# Usage:
- Plug in Leap motion, orient it to face towards the Ceiling
- Open Ryutai.pde in Processing 3.3.6
-- Ryutai depends upon Bubble.pde, however Processing should automatically load Bubble.pde in a different tab
- Click the 'Play' button to run Ryutai
- Move hands up/down/left/right over the leap motion sensor to create a rainbow liquid/smoke effect!
-- Currently forwards/backwards motion is unbound
- Touch the bubbles with the liquid to play a gong sound!


# Troubleshooting:

Q: Leap Motion not detected in Processing

A: Install device drivers from https://www.leapmotion.com/setup/ 


Q: Framerate extremely low / Crash on launch

A: The shaders used to render the liquid effect are very graphics intensive. 
There is a parameter named 'constraint' in the code which can be increased in order to decrease the load on the hardware and thus increase performance.
Test the performance on your machine and decide on the best constraint paramater that works for you. I recommend starting with 10.
