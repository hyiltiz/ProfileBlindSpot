function data=ProfileBlindSpot()
%
% Allow observer to use the mouse to actively trace out the blind spot.
%
% See also: PsychDemos, MouseTraceDemo, GetMouse.
%
% HISTORY
%                       
% 7/30/11  mk       Derived from MouseTraceDemo2.
% 9/23/21  hyiltiz  Derived from MouseTraceDemo3.
%
%

cursorHz = 5;
% Must be manually measured as the values reported by the graphics drivers are
% not always reliable
displayWidthMm = 382.5;

AssertOpenGL;
justRunQuietly = true;
if justRunQuietly
  Screen('Preference', 'SkipSyncTests', 1);
  Screen('Preference', 'VisualDebugLevel', 0);
  Screen('Preference', 'SuppressAllWarnings', 1);
else
  % this runs with all the quality guarantees and logs enabled
  Screen('Preference', 'SkipSyncTests', 0);
  Screen('Preference', 'VisualDebugLevel', 2);
  Screen('Preference', 'SuppressAllWarnings', 0);
end
KbName('UnifyKeyNames');
ListenChar(2);


qKey = KbName('q');

% if ~IsLinux
%   error('Sorry, this demo currently only works on Linux.');
% end

try
  % Open up a window on the screen and clear it.
  whichScreen = max(Screen('Screens'));
  [theWindow,theRect] = Screen('OpenWindow', whichScreen, 0);
  % Enable alpha blending with proper blend-function. We need it
  % for drawing of smoothed points:
  Screen('BlendFunction', theWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  % Use an offscreen window as drawing canvas:
  wOff = Screen('OpenOffscreenWindow', theWindow, 0);
  
  % Specify the font so regardless of system defaults, we always use the
  % same font
  Screen('TextFont',theWindow, 'Helvetica');
  Screen('TextSize',theWindow, 16);
  Screen('TextFont',wOff, 'Helvetica');
  Screen('TextSize',wOff, 16);
  % fprintf('The font is %s\n', Screen('TextFont',theWindow));
    
  cx=theRect(RectRight)/2;
  cy=theRect(RectBottom)/2;
  
  [width, height]=Screen('DisplaySize', whichScreen);
  resolution = Screen('resolution', whichScreen);
  mmPerPix =  width / resolution.width;
  % ensure the display spans 40 degs horizontally
  viewDistcm = (width/2)/tand(40/2) / 10;
  blindSpotCenterEstimateDeg = 15;  % blind spots typically range at 12-18 deg
  blindSpotCenterEstimatePx = viewDistcm*10 * tand(blindSpotCenterEstimateDeg)/mmPerPix;


  % Get handles for all virtual pointing devices, aka cursors:
  mice = GetMouseIndices('masterPointer');

  % Move the virtual cursors close to the center of the screen
  for mouse = mice
    theX(mouse+1) = cx + blindSpotCenterEstimatePx;
    theY(mouse+1) = cy;
    SetMouse(theX(mouse+1), theY(mouse+1), whichScreen, mouse);
    col = 255*[1 0 0; % red
               0 1 0; % green
               0 0 1; % blue
               1 1 0; % yellow
               1 1 1; % bright
               0 0 0; % dark
              ]; % color combinations

    % Hide the system-generated cursors. We do this, because only the
    % first mouse cursor is hardware-accelerated, ie., a GPU created
    % hardware cursor. All other cursors are software-cursors, created
    % by the Windowing system. These tend to flicker badly in our use
    % case. Therefore we disable all system cursor images and draw our
    % cursors ourselves for a more beautiful look:
    HideCursor([], mouse);
  end

  % Some instructions, drawn into the drawing canvas:
  Screen(wOff,'FillRect',0);  % dark background
  DrawFormattedText(wOff,sprintf('Throughout the experiment: rest your chin no further than %.1f cm in front of the red point firmly, cover one eye, and maintain fixation.\nDrag a mouse until the cursor just disappears then click to mark the point within your blind spot. Repeat to trace a blind spot region.\nClick right mouse anywhere to erase your last mark if you made a mistake. When done, cover the other eye and repeat. Press q key to save and exit.', viewDistcm), 20, 20, 255);
  % Fixation is at the center of the screen
  Screen('DrawDots', wOff, [cx cy], 5, 255*[1 0 0], [], 2);

  % Wait for release of all keys on all keyboards:
  KbReleaseWait(-3);

  % Stay in redraw loop as long as no key on any keyboard pressed:
  t = GetSecs;
  XY = [];
  while true
    [isKeyPressed,keyTime,keyCode] = KbCheck(-3);
    if any(keyCode(qKey))
        break
    end

    % Blit offscreen window with users scribbling into onscreen window:
    Screen('DrawTexture', theWindow, wOff);

    % Check all masterpointer mouse/pointing devices:
    for mouse = mice
      [x(mouse+1), y(mouse+1), buttons] = GetMouse(theWindow, mouse);
      if buttons(1) % left-mouse-button
        % Update offscreen window with latest scribbling from user for this 'mouse':
        if (x(mouse+1) ~= theX(mouse+1) || y(mouse+1) ~= theY(mouse+1))
          Screen('DrawDots', wOff, [x(mouse+1), y(mouse+1)], 1, 99*[1 1 1], [], 2);
          theX(mouse+1) = x(mouse+1); theY(mouse+1) = y(mouse+1);
          XY = [XY; x(mouse+1) y(mouse+1)];
          WaitSecs(0.10); % wait 100 ms after each datum
        end
      end

      if buttons(3) && ~isempty(XY)
          % right mouse button removes the previous datum, as a mistake
          % erase the last datum from the buffer
          Screen('DrawDots', wOff, [XY(end,1), XY(end,2)], 1, [0 0 0], [], 2);
          XY(end,:) = [];
          WaitSecs(0.30); % wait 300 ms after each mistake regret
      end

      % Draw a dot to visualize the mouse cursor for this 'mouse:
      Screen('DrawDots', theWindow, [x(mouse+1), y(mouse+1)], 5, col(1, :), [], 2);
      if GetSecs - t > 1/cursorHz
          % Switch the cursor color every 200 ms to maximize saliency
          col = col([2:end 1], :);
          t = GetSecs;
      end
    end

    % Flip the updated onscreen window:
    Screen('Flip', theWindow);
  end

  % Final measurements of the physical geometric setting of the experiment
  Screen('DrawTexture', theWindow, wOff);
  Screen('Flip', theWindow, 0, 1);
  DrawFormattedText(theWindow,sprintf('Using a measure stick and without moving your head, measure the distances between the red fixation dot and your eyes.'), 20, 2*cy-80, 255);
  [eyeDistanceL,terminatorChar]=GetEchoString(theWindow,'Left eye viewing distance (mm): ',20,2*cy-80,255,0,1,-3);
  [eyeDistanceR,terminatorChar]=GetEchoString(theWindow,'Right eye viewing distance (mm): ',20,2*cy-60,255,0,1,-3);
  [displayWidthMm,terminatorChar]=GetEchoString(theWindow,'Display screen width (mm): ',20,2*cy-40,255,0,1,-3);
  viewingDistanceMm = {eyeDistanceL, eyeDistanceR};
  % Screen('DrawTexture', theWindow, wOff);
  Screen('Flip', theWindow);

  % the data
  imgWOff = Screen('GetImage', wOff);
  datafile = ['ProfileBlindSpot-' datestr(now, 'yyyymmddHHMMSS')];
  imwrite(imgWOff,  [datafile '.png']);
  fprintf('Saved the data at %s/%s\n', pwd, datafile);

  % store data into the structure to be returned
  data = struct();
  data.img = imgWOff;
  data.XY = XY; 
  data.viewingDistanceMm = viewingDistanceMm;
  data.resolution = resolution;
  data.mmPerPix = displayWidthMm / data.resolution.width;
  save([datafile '.mat']', '-v7', '-struct', 'data');

  % Show master cursors again:
  for mouse = mice
    ShowCursor('Arrow', [], mouse);
  end

  sca;
  ListenChar(0);


  % plot basic analysis result
  instructionHeight = 80;
  % Create Gaussian filter matrix:
  [xG, yG] = meshgrid(-50:50);
  sigma = 10;
  g = exp(-xG.^2./(2.*sigma.^2)-yG.^2./(2.*sigma.^2));
  g = g./sum(g(:));
  data.g = g;
  fixationRemoved = data.img();
  fixationRemoved(cx+[-10:10], cy+[-10:10],:)=0;
  % generate a heatmap through a gaussian kernel
  imagesc(conv2(double(fixationRemoved(instructionHeight:end,:,1)>0), g, 'same'));
  colormap gray
  hold on
  axis image
  plot(cx, cy-instructionHeight, 'ro');
  plot(data.XY(:,1), data.XY(:,2)-instructionHeight, 'r.');
  hold off

  analyzeBlindSpot(data);
catch
  sca;
  ListenChar(0);
  psychrethrow(psychlasterror);
end %try..catch..


function analyzeBlindSpot(dat)

%% load data

% dat = load('sample.mat');

% displayWidthMm = 382.5;  % manually measured
% dat.mmPerPix = displayWidthMm / dat.resolution.width;

% plot raw data
figure
imshow(dat.img);

%% re-center w.r.t. the fixation, which was at the center of the screen
X = dat.XY(:,1) - dat.resolution.width/2;       % positive goes right
Y = -(dat.XY(:,2) - dat.resolution.height/2);   % positive goes up

% only consider the right eye for now
d = str2double(dat.viewingDistanceMm(1)) / dat.mmPerPix; % work in pix

%% Plot the eyeball

% transform into sperical coordinates of the visual field

% cornea is the center of the coordinate system
% theta swipes from front to right
% phi swipes from front to up
% rho is the distance from cornea to the visual target
theta = atan(X/d);      % azimuth angle, ie eccentricity
phi = atan(Y/d);        % elevation angle
rho = sqrt(X.^2 + Y.^2 + d.^2) * dat.mmPerPix; % corneal distance, in mm

% trace the boundary with the tightest polygon
j = boundary(theta, phi, 1);

% Map unto the retina
% Using the center of the eyeball as the center of the new system
% the coordinate system "faces" towards the retinal fovea
corneaRetinaDiameterMm = 17; % of a normal relaxed eye
r = corneaRetinaDiameterMm/2; % radius

% Trigonometry: central angle is twice the inscribed angle of the same arc
eyeTheta = pi/2-2*theta;  % visual field right projects into right
eyePhi = -2*phi;  % up projects into down
[retinaX, retinaY, retinaZ]=sph2cart(eyeTheta, eyePhi, r);


% legend square of 1mm
unitArcMm = 1;
unitCentralAngle = unitArcMm/r;
angleGrid = 0:0.01:unitCentralAngle;
[hX, hY, hZ]=sph2cart(median(eyeTheta)+angleGrid, pi/50+max(eyePhi)*ones(size(angleGrid)), r);
[vX, vY, vZ]=sph2cart(median(eyeTheta)*ones(size(angleGrid)), pi/50+max(eyePhi)+angleGrid, r);


% plot the eyeball
fh = figure;
[SX, SY, SZ] = sphere(100);
surf(r*SX, r*SY, r*SZ, 'FaceAlpha', 0.4, 'FaceColor', [0.9 0.8 0.6], 'EdgeColor', 'none');
colormap gray;
hold on
pupilDiameterMm = 4; 
scatter3(0, -r, 0, 100, [0 0 0]);

text(-0.1*r, -r, 0, '\leftarrow Pupil');
% scatter3(retinaX, retinaY, retinaZ, 1, [1 0 0]);
% plot3(retinaX(j), retinaY(j), retinaZ(j), 'r-');
scatter3(0, r, 0, 10, [1 0 0], 'filled');
text(-0.1*r, r, 0, '\leftarrow Fovea');
fill3(retinaX(j), retinaY(j), retinaZ(j), [0.4 0 0]);
text(cosd(65)*r, sind(95)*r, sind(8)*r, '\leftarrow Blind spot');

plot3(hX, hY, hZ, '-k');
plot3(vX, vY, vZ, '-k');
text(0.5*r, 0.85*r, 0.38*r, 'mm^2');
% text(max(hX)-0.5, min(vY)-0.5, median(vZ), 'mm^2');


xlabel('x');
ylabel('y');
box off
axis equal
% shading interp
view([0 1 0.3]);
hold off
camlight headlight
material dull
axis off
% axis vis3d
% title('Blind spot on the retina');
% text(r, 0, -1.2*r, 'Illustrated from behind the right retina');


%% create gif
fCount = 100;
f = getframe;
[im, map] = rgb2ind(f.cdata, 256,'nodither');
im(1, 1, 1, fCount) = 0;
IM = {};
k = 1;

% spin right
for i = 1:fCount
  [ez, el] = view();
  deltaEyeTheta = -1 * sind(i*360/fCount);
  view([ez+deltaEyeTheta, el]);
  f = getframe;
%   im(:,:,1,k) = rgb2ind(f.cdata, map, 'nodither');
  IM{i} = rgb2ind(f.cdata, map, 'nodither');
end

canvas = [max(cellfun(@(x) size(x,1), IM)), max(cellfun(@(x) size(x,2), IM))];
holdStatic = 50;
track = [1:numel(IM)/2 numel(IM)/2+zeros(1,holdStatic) numel(IM)/2+1:numel(IM) numel(IM)+zeros(1,holdStatic)]; 
im = uint8(zeros([canvas 1 numel(track)]))+IM{1}(1);
for i=1:numel(track)
  xIM = IM{track(i)};
  extraCanvas = canvas - size(xIM);
  x0 = 1+floor(extraCanvas(1)/2);
  y0 = 1+floor(extraCanvas(2)/2);
  im(x0:x0+size(xIM,1)-1, y0:y0+size(xIM,2)-1,1,i) = uint8(xIM);
end
imwrite(im,map,'Animation.gif','DelayTime', 0.05, 'LoopCount',inf)

%% draw the visual field
fh = figure();
xd=theta/pi*180;
yd=phi/pi*180;
box off
hold on;
plot(xd(j),yd(j), 'r-');
patch(xd(j),yd(j), [0.2 0 0]);
scatter(xd, yd, 1, [1 1 1]*0.2);
axis equal
axis([0 25 -10 10]);

set(gca, 'Color', [1 1 1]*0,...
 'XColor','k','YColor','k',...
 'XTick', 0:10:40,...
 'YTick', -10:10:10,...
 'LineWidth',2,...
 'TickDir','out',...
 'XMinorTick', true,...
 'YTickLabel', {'Down', 'Front', 'Up'},...
  'XTickLabel', {'Front', '10 deg', '20 deg'},...
 'YMinorTick', true);
title('Blind spot');
subtitle('Visual field of the right eye')
% ylabel('Vertical (deg)');

end

end
