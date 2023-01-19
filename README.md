# Applying Stimuli Propagation to a Design - Part 1
## Background story

After consuming the contents of an earlier post [1], [UVM Hello World](https://github.com/mjhborja/hello_world_uvm), the engineer is now capable of generating stimuli from a UVM test bench to a design under verification (DUV / DUT), his / her manager wants to put this investment to good use by asking him / her to exercise a specific design - an APB slave. 

And then the manager gives the engineer three things:
1. The DUV / DUT from [\[0\]](https://www.edaplayground.com/x/ueMH);
2. A piece of legacy test bench source code from [\[0\]](https://www.edaplayground.com/x/ueMH); and 
3. A protocol specification of ARM AMBA APB from [\[2\]](https://documentation-service.arm.com/static/60d5b505677cf7536a55c245?token=).

Do you think this is sufficient input to accomplish the task at hand?

Before answering that question, let us proceed with what we will learn from this post.

## What will you learn here?

You get to apply stimuli, which is what you learned from [1], to exercise a design. Cool!

### What do we know?

The design has an APB slave interface to it. That’s what we’ll use to make the test bench talk to the design and exercise its features.

### What don’t we know?

A lot actually, but based on what your manager asked you to do, what we know is more than enough at least to get you started. First, let's tackle these two questions. What is an APB slave? And what should we expect the test bench to do with it?

## Working with an interface protocol

In this series of posts, this is the first design that we come across. And every design interacts with its environment using interface protocols. The DUV in this post uses APB.

APB stands for Advanced Peripheral Bus, one of the earlier interface protocols ARM established with its AMBA library, which it uses to architect its processor cores [2]. APB is a low power bus protocol designed to cater to, as its name suggests, peripheral devices. These are the less demanding devices when it comes to performance.

### Interface signals

Looking at the signals of the DUV, it has 7 inputs and 2 outputs. It has a PREADY, which is the reason why we are using [2] instead of earlier versions of the APB protocol. Note that in [2], the terms master and slave are referred to as requester and completer, respectively. Also, the prefix P is designated for APB signals in the AMBA protocol library.
|Signal Name | Source | Description|
|------------|--------|------------|
|PCLK|System peripheral bus clock|synchronizes timing of all APB signals with its rising edge|
|PRESETn|System bus reset|active-low reset|
|PADDR|Requester|APB shared address|
|PSEL|Requester|indicates completer selection|
|PENABLE|Requester|indicates 2nd and subsequent transfer cycles|
|PWRITE|Requester|indicates the direction of the data transfer with respect to the requester|
|PWDATA|Requester|transfers data from requester to completer (may be byte, halfword, word long)|
|PRDATA|Completer|transfers data from completer to reqeuester (may be byte, halfword, word long)|
|PREADY|Completer|inserts wait states from completer|

The PREADY signal makes the APB bus transfer a 3-signal handshake instead of a 2-signal handshake with just PSEL and PENABLE as shown in the next section.

### Operating state machine

As the state diagram suggests, a transfer begins with the requester selecting the target completer device with PSEL = 1 and PENABLE = 0. This indicates transition into the SETUP state for one clock cycle. In the next cycle, the requester modifies PENABLE to 1 to enter the ACCESS state while holding PADDR, PWRITE and, in case of a write transfer, PWDATA unchanged. Finally, the completer signals completion by setting PREADY to 1. This sends the state machine either to IDLE or SETUP depending on whether the requester signals another transfer right after or not. 
\
![diagram_003 1-stimuli_apb_p1_state_diagram](https://user-images.githubusercontent.com/50364461/213482327-6fb1309a-185d-4c20-a95e-8c54c8507538.png)
#### APB operating states - diagram courtesy of [2]

With just those few sentences, we already captured the essence of APB. And now, we are in a position to run the simulation to see what it does prior to making any changes in the stimuli it generates.

## Simulate & play with the code
[0] EDA Playground Example - APB UVM With Scoreboard _ by an unknown author https://www.edaplayground.com/x/ueMH

## Additional references
[1] M. J. H. Borja, “UVM Hello World,” GitHub, Jan. 13, 2023. https://github.com/mjhborja/hello_world_uvm (accessed Jan. 19, 2023).
\
[2] AMBA APB Protocol Specification. Cambridge, England: Arm Ltd., 2021. Accessed: Jan. 19, 2023. [Online]. Available: https://documentation-service.arm.com/static/60d5b505677cf7536a55c245?token=
