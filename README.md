## Mental Navigation in MEG

There are two versions of the task.

1. Exploration
2. Navigation

Participants perform maximum 5 minutes of exploration before the experiment to get familiar with a sequence they have to navigate. After exploration, participants navigate the sequence to stop at the correct position.

### Dependencies

Psychtoolbox

```matlab
%% Run if ptb not working
currentFolder = pwd;
 
cd('/Applications/Psychtoolbox') % update this path with your psychtoolbox path
SetupPsychtoolbox
 
cd(currentFolder)
```
### Folder structure
```bash
.
|-- animals # images of animals 
|   |               `-- cat
|   |               `-- cow
|   |               `-- dog
|   |               `-- fox
|   |               `-- mouse
|                   `-- rooster
|-- input # input files of trial structure
|                   `-- pilot
|-- instructions # instruction images 
|   |               
|    `-- explore
|   |   |-- eng
|   |   |           `-- instructions
|   |   |-- ita
|   |               `-- instructions
|   `-- navigate
|       |-- eng
|       |           `-- instructions
|       |-- ita
|                   `-- instructions
|-- notebooks
|-- trial # contains code to load different phases of a trial
`-- utils # contains code for environment setups and files required for eye tracker and MEG setup
    |-- env
    |-- eye
    |-- meg
```

## Phase Behavior Specification

This section summarizes the current trial-phase behavior in the navigation task, with emphasis on start-key (`b`) handling and stop conditions.

### Start Key Convention

- Start/hold key: `b`
- Abort key: `ESCAPE`

---

### 1. Speed Cue

- The speed cue runs in a loop and can be ended with `b`.
- It enforces a minimum of one full loop before `b` is allowed to end the phase.
- If `ESCAPE` is pressed, the task aborts.

---

### 2. Blink Fixation

- Blink fixation runs as a full blink cycle ending in green.
- If `b` is pressed at any point during the cycle, this is latched as a valid start request.
- The phase does not exit immediately on press; it exits only after the current blink cycle finishes (green phase included).
- If `b` is not pressed during a cycle, blink fixation repeats.
- If `ESCAPE` is pressed, the task aborts.

---

### 3. Sample

- The participant must keep holding `b` during sample display.
- If `b` is released at any point during sample, sample is marked as hold-broken.
- On hold-broken, flow returns to blink fixation and must satisfy blink/start conditions again before re-entering sample.
- If `ESCAPE` is pressed, the task aborts.

---

### 4. Movement

- Movement starts only after sample is completed with valid hold behavior.
- Participant must keep holding `b` for movement to continue.
- Movement stops when either condition occurs first:
- `b` is released.
- `endT` (movement duration limit) is reached.
- If `ESCAPE` is pressed, the task aborts.

---

### 5. Probe

- Probe response uses `LeftArrow` or `RightArrow`.
- Probe response is independent of whether `b` is currently held or released.
- If `ESCAPE` is pressed, the task aborts.

---

### 6. Feedback

- Feedback is shown for its configured duration.
- After feedback duration elapses, the phase waits until all keys are released before continuing.
- If `ESCAPE` is pressed, the task aborts.

---

### 7. ITI

- ITI waits at least the configured ITI duration.
- After that minimum duration, progression is blocked until `b` is pressed.
- If `ESCAPE` is pressed, the task aborts.

## Trial Timeline

The trial runs in this order:

1. `Speed Cue`
2. `Blink Fixation`
3. `Sample`
4. `Movement`
5. `Probe` (probe trials) or `Feedback` (non-probe / early-stop branches)
6. `ITI`

### Timeline With Control Flow

1. `Speed Cue`:
- Runs continuously.
- Can end only after at least one full loop and a valid `b` press.

2. `Blink Fixation`:
- Executes a full blink cycle (ending in green).
- If `b` was pressed at any point in that cycle, continue to `Sample`.
- If not, run another blink cycle.

3. `Sample`:
- Participant must hold `b` during sample.
- If hold is broken, return to `Blink Fixation`.
- If hold is maintained, continue to `Movement`.

4. `Movement`:
- Starts after successful sample hold.
- Stops on first of:
- `b` release.
- `endT` reached.

5. Post-movement branch:
- Probe-path trial: go to `Probe`.
- Non-probe / feedback-path trial: go to `Feedback`.

6. `Probe` (if present):
- Collect `LeftArrow` / `RightArrow` response.
- Then continue onward.

7. `Feedback` (when scheduled):
- Show feedback for configured duration.
- Wait until all keys are released.

8. `ITI`:
- Wait minimum ITI duration.
- Then wait for `b` press to start next trial.

NOTES
6. Look into literature , for EMG points for muscle (hands & feet)

8. Flip the screen using cmd code so it shows correct way in projector:
        vputil in desktop run : -1:(ANY DEVICE) > pm r
