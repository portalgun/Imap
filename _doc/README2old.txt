%function [P] = daVinciZonePatches(imgNum,IctrRC,dspArcMin,fgndORbgnd,nSmpPerImg,PszXY,LorR,plotFlag,Lpht,Rpht,Lrng,Rrng,Lxyz,Rxyz,LppXm,LppYm,RppXm,RppYm,Ldvn,Rdvn)
%
%  Make half occluded patches from preselected image centers
%
%  example call;
%       IctrRC=daVinciZoneSample(1,[130 52],'L',edg,18,'slice',[0 13],.2,1,1);
%       P=daVinciZonePatches(1,[130 52],'L',IctrRC,-3.5,'fgnd',20,1)
%
%
%  INPUTS
%  imgNum      - range of images to sue from    [numImages x 1]
%  PszXY       - desired horizontal by vertical patch size [1 x 2]
%  LorR        - what to use as an anchor
%                'L' -> only use left eyes as anchor
%                'R' -> only use right eye as anchor
%  IctrRC      - vedted patch centers [maxSmp x 2]
%  dspArcMin   - how much disparity in arcMinutes to add to stereo-patches
%  fgndORbgnd  - Whether to have cyclopian focus on the foreground or background
%  nSmpPerImg  - number of samples per image desired. Determined from nSmp if unspecified.
%  plotFlag - whether to plot and/or which part of the image to plot
%                0 -> do not plog
%                1 -> plot for only L or R anchor only (whatever is being used)
%                2 -> plot for Left anchor
%                3 -> plot for RIght anchor
%                2 & 3 are meant to be used in a loop
%  Lpht     - left luminance image            [PszXY(2) x PszXY(1) ]
%  Rpht     - right luminance image           [PszXY(2) x PszXY(1) ]
%  Lrng     - left range image                [PszXY(2) x PszXY(1) ]
%  Rrng     - right range image               [PszXY(2) x PszXY(1) ]
%  Lxyz     - left cartesian range image      [PszXY(2) x PszXY(1) x 3]
%  Rxyz     - right cartesian range image     [PszXY(2) x PszXY(1) x 3]
%  LppXm:   - x-position ( meters ) of pixels in '(p)rojection (p)lane' for left  eye coordinate system
%  LppYm:   - y-position ( meters ) of pixels in '(p)rojection (p)lane' for left  eye coordinate system
%  RppXm:   - x-position ( meters ) of pixels in '(p)rojection (p)lane' for right eye coordinate system
%  RppYm:   - y-position ( meters ) of pixels in '(p)rojection (p)lane' for right eye coordinate system
%  Ldvn     - left DaVinci image              [PszXY(2) x PszXY(1) ]
%  Rdvn     - right DaVinci image             [PszXY(2) x PszXY(1) ]
%
%  rootDTBdir      - root directory of database, exlcuding the 'LRSI' directory
%
%
%  OUTPUTS
%  P               - struct containing the following:
%          LitpRCchkDsp- Left image patch center after adding disparity.
%                            Also the 'check' version of LitpRCall, meaning it uses the opposite eye to
%                            find the corresponding point, and thus is centered on the occluding
%                            surface.
%                            [nSmp x 2]
%
%          RitpRCchkDsp- Right image patch center after adding disparity.
%                            Also the 'check' version of RitpRCall, meaning it uses the opposite eye to
%                            find the corresponding point, and thus is centered on the occluding
%                            surface.
%          LitpRCchk- Left image patch center before adding disparity
%          RitpRCchk- Right image patch center before adding diparity
%          LitpRCall       - Left image patch center of occluded region defined by daVinciZoneCenter
%                            if using left anchor, or found using LRSIcorrespondingPointVec if using
%                            right anchor
%          RitpRCall       - Right image patch center of occluded region defined by daVinciZoneCenter
%                            if using right anchor, or found using LRSIcorrespondingPointVec if using
%                            left anchor
%          LitpRCdsp- Right image patch center after adding disparity.
%          RitpRCdsp- Left image patch center after adding disparity.
%          LphtCrp- cropped luminance images centered on LitpRCchkDsp
%                            [PszXY(2) x PszXY(1) x nSmp]
%          LphtCrpZer - cropped luminance images centered on LitpRCchk (no disparity added)
%                            [PszXY(2) x PszXY(1) x nSmp]
%          LrngCrp- cropped range images centered on LitpRCchkDsp
%                            [PszXY(2) x PszXY(1) x nSmp]
%          LxyzCrp- cropped cartesian range images centered on LitpRCchkDsp
%                            [PszXY(2) x PszXY(1) x 3 x nSmp]
%          LdvnCrp- cropped DaVinci images centered on LitpRCchkDsp
%                            [PszXY(2) x PszXY(1) x nSmp]
%          LppXmCrp-
%                            [PszXY(2) x PszXY(1) x nSmp]
%          LppYmCrp-
%                            [PszXY(2) x PszXY(1) x nSmp]
%          RphtCrp- cropped luminance images centered on LitpRCchkDspA
%                            [PszXY(2) x PszXY(1) x nSmp]
%          RrngCrp- cropped range images centered on LitpRCchkDsp
%                            [PszXY(2) x PszXY(1) x nSmp]
%          RxyzCrp- cropped cartesian range images centered on LitpRCc
%                            [PszXY(2) x PszXY(1) x 3 x nSmp]
%          RdvnCrp- cropped DaVinci images centered on LitpRCchkDsp
%                            [PszXY(2) x PszXY(1) x nSmp]
%          RppXmCrp-
%                            [PszXY(2) x PszXY(1) x nSmp]
%          RppYmCrp-
%                            [PszXY(2) x PszXY(1) x nSmp]
%
% --------------------------------------------------------------------
