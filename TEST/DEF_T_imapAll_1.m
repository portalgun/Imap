%%%%%%%%%%%%%%%
%ALL
%base.alias='test_all'
base.database='LRSI';
base.imgNums=1:98;
base.LorRorB='B';
base.mode=[1:3]; %1-3, 3-6

%%%%%%%%%%%%%%%
% PlotOpts
plotOpts=struct();
plotOpts.bProg=1;

%%%%%%%%%%%%%%%
%% VET
vet=struct();
% DVN
dvn=struct();
dvn.PszXY=[53 53];
dvn.bVetAgainst=[1 1];
dvn.minCntrSep=[10 10];
% NAN
xyzNan=struct();
xyzNan.PszXY=[53 53];
xyzNan.bVetAgainst=[1 1];
xyzNan.minCntrSep=[10 10];
%xyzNan.bVetAtComb=[1 1];
% Package
vet.xyzNan=xyzNan;
vet.dvn=dvn;
vet.plotOpts=plotOpts;
vet.plotOpts.bPostAt=1;
vet.plotOpts.bPostIn=1;

%%%%%%%%%%%%%%%
%% GEN
gen=struct();
% type
type=struct();
type.name='disparity_contrast';
type.setParams=struct();
type.setParams.Wk=100;
type.setParams.kernSz=[52 52];
% typeL
typeL=cell(1);
typeL{1}=struct();
typeL{1}.name='disparity_contrast_2';
typeL{1}.minMax=[0 3];
typeL{1}.setParams=struct();
typeL{1}.setParams.Wk=100;
typeL{1}.setParams.kernSz=[52 52];
% PACKAGE
gen.type=type;
gen.typeL=typeL;
gen.plotOpts=plotOpts;

%%%%%%%%%%%%%%%
%% BIN
bin=struct();
bin.nBin=50;
bin.bLogBin=0;
% Package
bin.plotOpts=plotOpts;

%%%%%%%%%%%%%%%
%% SMP
smp=struct();
smp.PszXY=[129 129]; % XXX
smp.rndSd=1;
smp.bSampleDouble=1;
smp.bBinOverlap=0;
smp.bCPoverlap=0;
smp.overlapPix=5;
smp.binNums=[]; % XXX
% Package
smp.plotOpts=plotOpts;


%%%%%%%%%%%%%%%
%% PCH
pch=struct();
pch.PszXY=[129 129];
pch.PszRCbuff=[149 149];
pch.mapNames={'pht','xyz'};
pch.mskNames=[];
pch.texNames=[];
pch.bStereo=1;
% Package
pch.plotOpts=plotOpts;

%%%%%%%%%%%%%%%
%% DSP
dsp=struct();

dsp.display='jburge-jburge_wheatstone';

subjInfo=struct();
subjInfo.LExyz=[];
subjInfo.RExyz=[];
subjInfo.IPDm=[];
% Package
dsp.subjInfo=subjInfo;

winInfo=struct();
%winInfo.WHm
%winInfo.WHpix
winInfo.WHdeg=[1 1];
%winInfo.WHdegRaw
winInfo.posXYpix=[0,0];
%winInfo.posXYpixRaw
%winInfo.vrgXY
%winInfo.vrsXY
dsp.winInfo=winInfo;

trgtInfo=struct();
trgtInfo.trgtDisp=[linspace(-15,0,192)];
trgtInfo.dispORwin='win';
%trgtInfo.posXYZm
trgtInfo.posXYpix=0;
%trgtInfo.posXYpixRaw
%trgtInfo.vrgXY
%trgtInfo.vrsXY
dsp.trgtInfo=trgtInfo;

focInfo=struct();
focInfo.dispORwin='disp';
focInfo.posXYZm=0;
%focInfo.posXYpix
%focInfo.posXYpixRaw
%focInfo.vrgXY
%focInfo.vrsXY
dsp.focInfo=focInfo;

% XXX
%wdwInfo=struct();
%dsp.wdwInfo=wdwInfo;

%%%%%%%%%%%%%%%
%% SEL
%sel=struct();
%sel.modes=[-1];
%sel.dmpName='test1';
%sel.bEobj=0;
%
%%DMP
%sel.nTrl
%sel.nCmpPerLvl
%sel.rndSd=1;
%
%%TRAIN/TEST
%sel.nBlk
%sel.nTrl
%sel.nCmpPerLvl
%sel.nIntrvl
%sel.rndSd
%sel.stdStruct
%
%prjInfo.prjCode;
%%prjInfo.imgDTB
%%prjInfo.natORflt
%%prjInfo.imgDim
%%prjInfo.method
%%prjInfo.prjInd
%%prjInfo.alias
%sel.prjInfo=prjInfo;
