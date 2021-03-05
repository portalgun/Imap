  Sample from DaVinci regions to find potential patch centers that satisfy the following:
   Are the center or leftmost pixel in the davinci region (ctrORedg)
   In a DaVinci region with a minimum width (minMaxPixMap(1)) and optionally w/ max (minMaxPixMap(2))
       This width Regions width extends through vertical of specified patch size
       [with some buffering (zoneBufferRC)
           OR (zoneTestType)
       DaVinci region within patch size meets a DaVinci density requirement
   Potential Patches do not overlap

   example call:
       smpRC=samplesMap(1,[130 52],'L',edg,18,'slice',[0 13],.2,1,1);
       daVinciZoneSample([52 52],'B',8,18,'bgn','slice',13,0,.2,1,rootDTBdir,1,8,[])

   INPUTS
   imgNum   - range of images to sue from DVN[numImages x 1]
               *Optional DVN3 including Lpht,Rpht,Lrng,Rrng,Lmap,Rmap
   PszXY    - patch size [2 x 1]
   LorR     - which anchor to use
              'L' -> Left eye ancho
              'R' -> Right eye anchor
              'B' -> Both eyes as anchors (individually not togehter)
   ctrORedg - whether the patch center is at the beginning or end of DaVinci region
   minMaxPixMap - [2 x 1]
              (1) minimum width of DaVinci region for patch center
              (2) maximum width of DaVinci region for patch center
                 'edg' -> patch center is at center pixel of DaVicni region
                 'bgn' -> patch center is at leftmost pixerl of DaVinci region
   nMapbuffer   - size of Map region in corresponding patch to be considered significant (superSlice method only)
   nMap         - number of Map regions allowed in each corresponding patch (superSlice method only)
   minZoneSep   - required horizontal distance between central and additional significant Map zones. (superSlice method only)
   zoneTestType - whether to use 'slice' or 'density' vetting for patch center
              'slice' - use slice method, where DaVinci region center width must be present
               within every row of the patch
              'superSlice' - slice method, but allows for non-significant Map zones, and allows
                             a specified number of sigificant Map zones if they are seperated
                             horizontally by a specified distance.
                             See nMapbuffer, nMap, minZoneSep.
              'density' - DaVinci region must have a specified density within patch region
   zoneBufferRC(2) - buffer for 'slice' method: width can be minMaxPixMap(1)-zoneBufferRC(2) in length
              to count as an extending region in patch area
   zoneBufferRC(1) - buffer for 'slice' method: if there are X number of rows in a patch, there
              must be X-zoneBufferRC(1) rows with width of minMaxPixMap(1)-zoneBufferRC(2) to be
              classified as a valid patch
   zoneMinDensity - density of DaVinci pixels to non-DaVinci pixels in patch region to be
              classified as a valid patch
   rndSd    - random seed to use for random sampling
              0 -> non-random sampling that maximizes number of samples
   plotFlag - whether to plot and/or which part of the image to plot
               0 -> do not plot
               1 -> plot for only L or R anchor only (whatever is being used)
               2 -> plot for Left anchor
               3 -> plot for RIght anchor
               2 & 3 are meant to be used in a loop
   Lpht     - left luminance image  [PszXY(2) x PszXY(1) ]
   Rpht     - right luminance image [PszXY(2) x PszXY(1) ]
   Lrng     - left range image      [PszXY(2) x PszXY(1) ]
   Rrng     - right range image     [PszXY(2) x PszXY(1) ]
   Lmap     - left DaVinci image    [PszXY(2) x PszXY(1) ]
   Rmap     - right DaVinci image   [PszXY(2) x PszXY(1) ]
   rootDTBdir - root directory of database, exlcuding the 'LRSI' directory
               *optional for burge lab - TODO add this functionality
   indLookup - index lookup table defined as:
                indLookup=reshape(1:(IszRC(1)*IszRC(2)),IszRC)
                defines this outside of this function and loops to make things speedy
   overlapPix- number of pixels patches are allowed to overlap vertically
  dspArcMin   - how much disparity in arcMinutes to add to stereo-patches
  fgndORbgnd  - Whether to have cyclopian focus on the foreground or background
  nSmpPerImg  - number of samples per image desired. Determined from nSmp if unspecified.



   OUTPUTS
   smpRC     - veted patch center subscripts  [maxSmp x 2]
   smpInd    - veted patch center indeces     [maxSmp x 1]

   ImapCtrRC  - left- or right-eye subscripts of zone centers
   ImapCtrInd - left- or right-eye indeces of zone centers
   widthAll   - widths of ImapCtr*

   PctrRC     - valid patch center subscripts
   PctrInd    - valid patch center index
              - struct containing the following:
          LitpRCchkDsp- Left image patch center after adding disparity.
                            Also the 'check' version of LitpRCall, meaning it uses the opposite eye to
                            find the corresponding point, and thus is centered on the occluding
                            surface.
                            [nSmp x 2]

          RitpRCchkDsp- Right image patch center after adding disparity.
                            Also the 'check' version of RitpRCall, meaning it uses the opposite eye to
                            find the corresponding point, and thus is centered on the occluding
                            surface.
          LitpRCchk- Left image patch center before adding disparity
          RitpRCchk- Right image patch center before adding diparity
          LitpRCall       - Left image patch center of occluded region defined by daVinciZoneCenter
                            if using left anchor, or found using LRSIcorrespondingPointVec if using
                            right anchor
          RitpRCall       - Right image patch center of occluded region defined by daVinciZoneCenter
                            if using right anchor, or found using LRSIcorrespondingPointVec if using
                            left anchor
          LitpRCdsp- Right image patch center after adding disparity.
          RitpRCdsp- Left image patch center after adding disparity.
          LphtCrp- cropped luminance images centered on LitpRCchkDsp
                            [PszXY(2) x PszXY(1) x nSmp]
          LphtCrpZer - cropped luminance images centered on LitpRCchk (no disparity added)
                            [PszXY(2) x PszXY(1) x nSmp]
          LrngCrp- cropped range images centered on LitpRCchkDsp
                            [PszXY(2) x PszXY(1) x nSmp]
          LxyzCrp- cropped cartesian range images centered on LitpRCchkDsp
                            [PszXY(2) x PszXY(1) x 3 x nSmp]
          LmapCrp- cropped DaVinci images centered on LitpRCchkDsp
                            [PszXY(2) x PszXY(1) x nSmp]
          LppXmCrp-
                            [PszXY(2) x PszXY(1) x nSmp]
          LppYmCrp-
                            [PszXY(2) x PszXY(1) x nSmp]
          RphtCrp- cropped luminance images centered on LitpRCchkDspA
                            [PszXY(2) x PszXY(1) x nSmp]
          RrngCrp- cropped range images centered on LitpRCchkDsp
                            [PszXY(2) x PszXY(1) x nSmp]
          RxyzCrp- cropped cartesian range images centered on LitpRCc
                            [PszXY(2) x PszXY(1) x 3 x nSmp]
          RmapCrp- cropped DaVinci images centered on LitpRCchkDsp
                            [PszXY(2) x PszXY(1) x nSmp]
          RppXmCrp-
                            [PszXY(2) x PszXY(1) x nSmp]
          RppYmCrp-
                            [PszXY(2) x PszXY(1) x nSmp]

 --------------------------------------------------------------------
 XXXX % function [P] = daVinciSamplePatch(varargin)

   example call:
      P = daVinciSamplePatchBatch();
      P = daVinciSamplePatchBatch(H);

 Handle batch processing of batch patch creation
    daVinciZoneSamplePatchBatch      - handle patch grabbing for given disparity and map width
    daVinciZoneSamplePatchBatchBatch - Loops over all specified disparities and widths
 --------------------------------------------------------------------
 INPUT:

 H - struct: SEE daVinciZoneParamParse FOR DETAILS ON H FIELDS (optional)
 --------------------------------------------------------------------
 OUTPUT:

 P               - struct containing the following:
   imgNumAll       - index of all images used for all other outputs  [nSmp x 1]
   LorRAll         - index of all anchors used for all other outputs [nSmp x 1]
   LctrCrp         - XXX [nSmp x 2]
   RctrCrp         - XXX [nSmp x 2]
   LitpRCchkDspAll - Left image patch center after adding disparity.
                              Also the 'check' version of LitpRCall, meaning it uses the opposite eye to
                              find the corresponding point, and thus is centered on the occluding
                              surface.
                              [nSmp x 2]

   RitpRCchkDspAll - Right image patch center after adding disparity.
                              Also the 'check' version of RitpRCall, meaning it uses the opposite eye to
                              find the corresponding point, and thus is centered on the occluding
                              surface.
   CitpRCchkDspAll - XXX
   LitpRCchkAll    - Left image patch center before adding disparity
   RitpRCchkAll    - Right image patch center before adding diparity
   LitpRCall       - Left image patch center of occluded region defined by daVinciZoneCenter
                     if using left anchor, or found using LRSIcorrespondingPointVec if using
                              right anchor
   RitpRCall       - Right image patch center of occluded region defined by daVinciZoneCenter
                     if using right anchor, or found using LRSIcorrespondingPointVec if using left anchor
   LitpRCdspAll    - Right image patch center after adding disparity.
   CitpRCdspAll    - XXX
   RitpRCdspAll    - Left image patch center after adding disparity.
   LphtCrpAll      - cropped luminance images centered on LitpRCchkDspAll
                     [PszXY(2) x PszXY(1) x nSmp]
   LrngCrpAll      - cropped range images centered on LitpRCchkDspAll
                     [PszXY(2) x PszXY(1) x nSmp]
   LxyzCrpAll      - cropped cartesian range images centered on LitpRCchkDspAll
                              [PszXY(2) x PszXY(1) x 3 x nSmp]
   LmapCrpAll      - cropped daVinci images centered on LitpRCchkDspAll
                              [PszXY(2) x PszXY(1) x nSmp]
   LppXmCrpAll     - cropped left eye projection plane pixel locations in X
                              [PszXY(2) x PszXY(1) x nSmp]
   LppYmCrpAll     - cropped left eye projection plane pixel locations in Y
                              [PszXY(2) x PszXY(1) x nSmp]
   RphtCrpAll      - cropped luminance images centered on LitpRCchkDspA
                              [PszXY(2) x PszXY(1) x nSmp]
   RrngCrpAll      - cropped range images centered on LitpRCchkDspAll
                              [PszXY(2) x PszXY(1) x nSmp]
   RxyzCrpAll      - cropped cartesian range images centered on LitpRCc
                              [PszXY(2) x PszXY(1) x 3 x nSmp]
   RmapCrpAll      - cropped daVinci images centered on LitpRCchkDspAll
                              [PszXY(2) x PszXY(1) x nSmp]
   RppXmCrpAll     - cropped right eye projection plane pixel locations in X
                              [PszXY(2) x PszXY(1) x nSmp]
   RppYmCrpAll     - cropped right eye projection plane pixel locations in Y
                              [PszXY(2) x PszXY(1) x nSmp]
   fig1            - XXX
   fig2            - XXX
   fig3            - XXX
     stmXYdeg       - size of
 --------------------------------------------------------------------
 PROPERTIES
