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