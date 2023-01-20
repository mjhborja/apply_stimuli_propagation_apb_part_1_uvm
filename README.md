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

You get to apply stimuli, which is what you learned from [1], to exercise a design and view it. Cool!

### What do we know?

The design has an APB slave interface to it. That’s what we’ll use to make the test bench talk to the design and exercise its features.

### What don’t we know?

A lot actually, but based on what your manager asked you to do, what we know is more than enough at least to get you started. First, let's tackle these two questions. What is an APB slave? And what should we expect the test bench to do with it?

## Working with an interface protocol

This is the first design that we come across in this series of posts that isn't just a stub. And every design interacts with its environment using interface protocols. The DUV in this post uses APB - standard interface.

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

### A few alterations
Note: The source code from [0] does not compile and run as is. That is the case for the Aldec Riviera Pro simulator. To be able to actually run the simulation, you will need to make a few changes. And since EDA Playground currently does not support integration with github or any similar repository management app, you will have to do this manually.

### 1. Start a web browser session of the [\[0\]](https://www.edaplayground.com/x/ueMH) playground
### 1.a. Open a new web browser window for [\[0\]](https://www.edaplayground.com/x/ueMH) playground
Right-click the link [\[0\]](https://www.edaplayground.com/x/ueMH), and select "Open Link in New Window." This opens a new window containing [\[0\]](https://www.edaplayground.com/x/ueMH). 
### 1.b. Log in to EDA Playground
Then, click the "Log in" button on the upper right of the web page as shown in the image below.
![diagram_003 2-alteration_1](https://user-images.githubusercontent.com/50364461/213665622-ec690e2a-914a-4f85-b0bd-88e036f99f61.png)
### 2. Log in
There are several options to log in to your account. If you do not wish to use a work or academic email account, you may either use your Google or Facebook account for a secure log in.
### 2.a. Log in with Google
For instance, to log in with your google account. Click the "Google" link as shown in the image below.
![diagram_003 3-alteration_2_a_log_with_google](https://user-images.githubusercontent.com/50364461/213669390-a974db9f-0f30-4ae0-821c-359a720e1edb.png)
### 2.b. Secure sign-in dialog
This opens a secure sign-in dialog from Google to edaplayground.com as shown in the image below.
![diagram_003 4-alteration_2_b_log_with_google](https://user-images.githubusercontent.com/50364461/213673498-a2bd01b7-98d8-49b3-9781-fcbaeb984398.png)
### 2.c. Select your account
Select your Google account that you wish to sign in with from the list as shown below and log in.
![diagram_003 5-alteration_2_c_log_with_google](https://user-images.githubusercontent.com/50364461/213673794-37c3d6d1-59f6-4ca1-aac3-28efe1d38c2b.png)
### 2.d. EDA Playground with simulation privileges
Since EDA Playground opens an empty playground upon successful log in reopen [\[0\]](https://www.edaplayground.com/x/ueMH). 
Repeat 1.a. This time the session is already logged into your profile.
![diagram_003 6-alteration_2_d](https://user-images.githubusercontent.com/50364461/213674558-ff0b0d3e-3575-4470-ac50-6466dfe92ccc.png)
### 3. Modify the files to avoid compilation errors inherent with the [\[0\]](https://www.edaplayground.com/x/ueMH) playground
### 3.a. testbench.sv
Modify the testbench.sv file according to the changes from the source code diff of [commit 664e098](https://github.com/mjhborja/apply_stimuli_propagation_apb_part_1_uvm/commit/664e09823514dd61f77a6811d5a414a7032b18bb#diff-fda45b215cf3ae262711db84d02001a9a0ce95cce58ee41c45e8f7b037b06cd9). Line 3.
![diagram_003 7-alteration_3_a](https://user-images.githubusercontent.com/50364461/213689149-8213727a-db14-4336-ac48-0d275179f1ef.png)
### 3.b. driver_apbm.sv
Modify the driver_apbm.sv file according to the changes from the source code diff of [commit 664e098](https://github.com/mjhborja/apply_stimuli_propagation_apb_part_1_uvm/commit/664e09823514dd61f77a6811d5a414a7032b18bb#diff-77ed52f72de40146c81fecdf0ac9814fdd158cbfe79b9930efe8a18620ed36f0). Line 26.
![diagram_003 8-alteration_3_b](https://user-images.githubusercontent.com/50364461/213691338-ead38684-9ffb-4b3f-9450-432a3f22e3c5.png)
### 3.c. Scoreboard_apb.sv
Modify the Scoreboard_apb.sv file according to the changes from the source code diff of [commit 664e098](https://github.com/mjhborja/apply_stimuli_propagation_apb_part_1_uvm/commit/664e09823514dd61f77a6811d5a414a7032b18bb#diff-74523d8f4ad59344ec1f6101f8f88b742bdff634ff5c54edf827311718b12539). Lines 84-87, 91-93, 97-98, and 102.
![diagram_003 9-alteration_3_c](https://user-images.githubusercontent.com/50364461/213715660-e9f9158c-8746-4f18-8563-850a3bac50f2.png)
### 3.d. run.do
Create a run.do file according to the source code diff of [commit 40e447d](https://github.com/mjhborja/apply_stimuli_propagation_apb_part_1_uvm/commit/40e447dd34d64db2c36a6f95a9717f8fb106b50a). All 3 lines.
![diagram_003 10-alteration_3_d](https://user-images.githubusercontent.com/50364461/213695208-8147cdc4-b257-4159-b9a2-42e2bca65f72.png)
### 4. Select simulator option
### 4.a. Tools & Simulators
Click "Tools & Simulators" to expand and show the options dropdown.
![diagram_003 11-alteration_4_a](https://user-images.githubusercontent.com/50364461/213695262-7530df6a-7610-4579-bf45-80ebc5b515b9.png)
### 4.b. Dropdown menu
Select "Aldec Riviera Pro 2022.04" from the Simulator dropdown menu.
![diagram_003 12-alteration_4_b](https://user-images.githubusercontent.com/50364461/213695292-5ccd76f3-ab52-4285-8413-01d8cd3b0824.png)
### 4.c. Simulator selected
![diagram_003 12-alteration_4_c](https://user-images.githubusercontent.com/50364461/213695320-5fda6170-6da1-4f43-b67c-dee80cbe9a95.png)
### 5. Enable run.do
Check the "Use run.do Tcl file" checkbox as shown in the diagram below. This overrides the default run command with what your run.do file contains. 
![diagram_003 13-alteration_5](https://user-images.githubusercontent.com/50364461/213695351-567e9dc4-6e9b-4ae8-a34a-d57f5b648b00.png)
### 6. Enable waveform viewing
Check the "Open EPWave after run" checkbox as shown in the diagram below. This enables waveform viewing using EDA Playground's waveform viewer. 

Trivia: EP comes from EDA Playground.
![diagram_003 14-alteration_6](https://user-images.githubusercontent.com/50364461/213695377-f8ff821b-eeff-4c43-970f-8ff78dc59c80.png)
### 7. Save the playground
Click the "Copy" Button as shown in the diagram below. This saves the current state of the playground into a new one.
![diagram_003 15-alteration_7](https://user-images.githubusercontent.com/50364461/213695401-34ac4720-f38f-47e2-b3c8-f8745627a2d3.png)
### 8. Run the simulation
Click the "Run" Button. This will trigger the compilation and simulation run process using the selected simulator.
![diagram_003 16-alteration_8](https://user-images.githubusercontent.com/50364461/213695430-48ea5afd-2d30-4383-b46f-17c1a987851c.png)
### 9. View the simulation waveform
When the option in 6. is enabled, the waveform viewer app is invoked immediately after the simulation finishes.
### 9.a. EPWave initial dialog
Close the EPWave dialog that appears.
![diagram_003 17-alteration_9_a](https://user-images.githubusercontent.com/50364461/213695457-a997a22f-2a86-478d-a620-508a716d1cb7.png)
### 9.b. EPWave interface
Click the "Get Signals" Button.
![diagram_003 18-alteration_9_b](https://user-images.githubusercontent.com/50364461/213695484-76ca735e-6369-4f04-a4ac-463e1b68ea95.png)
### 9.c. EPWave select signals dialog
In the "Get Signals to Display" dialog, select ".dut_slave" from the "Scope" list. This loads all nets under the ".dut_slave" hierarchy.
![diagram_003 19-alteration_9_c](https://user-images.githubusercontent.com/50364461/213695501-2c7daf61-4a8e-43c0-91f1-d03d0a3aff54.png)
Click the "Append All" button to include the selection into the waveform viewer's current window.
![diagram_003 20-alteration_9_c](https://user-images.githubusercontent.com/50364461/213695522-c49832b0-28c5-4b53-9452-f781f7e0ef98.png)
Congratulations! You now have your waveform.
![diagram_003 21-alteration_9_c](https://user-images.githubusercontent.com/50364461/213689794-7675f6d1-46d1-4620-acc2-109d3856b3be.png)

Now you can start exploring the waveform dump generated by the simulation run. While exploring, keep in mind the sections on Interface Signals and Operating State Machine. From there, you can evaluate how your test bench stimuli behave against the APB protocol standard. But we'll leave that for part 2.

That's it for this post. And happy waveform checking!

## Key takeaways
__*learning interface protocols*__, __*waveform viewing*__

## Additional references
[1] M. J. H. Borja, “UVM Hello World,” GitHub, Jan. 13, 2023. https://github.com/mjhborja/hello_world_uvm (accessed Jan. 19, 2023).
\
[2] AMBA APB Protocol Specification. Cambridge, England: Arm Ltd., 2021. Accessed: Jan. 19, 2023. [Online]. Available: https://documentation-service.arm.com/static/60d5b505677cf7536a55c245?token=
