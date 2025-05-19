clc; clear; close all;

% === User Settings ===
tpmsType = 'gyroid';   % Options: 'gyroid', 'schwarz', 'diamond', 'lidinoid', 'neovius'
domainSize = 40;       % Size of cube in mm
gridSize = 100;        % Grid resolution (higher = better quality)
scaleFactor = 2;       % Number of TPMS cells in the domain
thickness = 0.5;       % Offset level from zero (surface thickness)

% === Coordinate Grid ===
[x, y, z] = meshgrid( ...
    linspace(0, domainSize, gridSize), ...
    linspace(0, domainSize, gridSize), ...
    linspace(0, domainSize, gridSize));

% === Scale Coordinates ===
scaledX = x * (2*pi*scaleFactor / domainSize);
scaledY = y * (2*pi*scaleFactor / domainSize);
scaledZ = z * (2*pi*scaleFactor / domainSize);

% === TPMS Equation Selection ===
switch lower(tpmsType)
    case 'gyroid'
        field = sin(scaledX).*cos(scaledY) + ...
                sin(scaledY).*cos(scaledZ) + ...
                sin(scaledZ).*cos(scaledX);
    case 'schwarz'
        field = cos(scaledX) + cos(scaledY) + cos(scaledZ);
    case 'diamond'
        field = sin(scaledX).*sin(scaledY).*sin(scaledZ) + ...
                sin(scaledX).*cos(scaledY).*cos(scaledZ) + ...
                cos(scaledX).*sin(scaledY).*cos(scaledZ) + ...
                cos(scaledX).*cos(scaledY).*sin(scaledZ);
    case 'lidinoid'
        field = sin(scaledX) .* sin(scaledY) .* sin(scaledZ) + ...
                sin(scaledX) .* cos(scaledY) .* cos(scaledZ) + ...
                cos(scaledX) .* sin(scaledY) .* cos(scaledZ) + ...
                cos(scaledX) .* cos(scaledY) .* sin(scaledZ) - ...
                sin(scaledX) .* sin(scaledY) - sin(scaledY) .* sin(scaledZ) - sin(scaledZ) .* sin(scaledX);
    case 'neovius'
        field = 3 * (cos(scaledX) + cos(scaledY) + cos(scaledZ)) + ...
                4 * cos(scaledX) .* cos(scaledY) .* cos(scaledZ);
    otherwise
        error('Unknown TPMS type selected.');
end

% === Make Geometry Solid ===
obj = (field - thickness) .* (field + thickness);

% === Mesh from Isosurface + Isocaps ===
[F1, V1] = isosurface(x, y, z, obj, 0);
[F2, V2] = isocaps(x, y, z, obj, 0, 'below');

F = [F1; F2 + size(V1, 1)];
V = [V1; V2];

% === Visualization ===
figure;
p = patch('Faces', F, 'Vertices', V);
p.FaceColor = 'red';
p.EdgeColor = 'none';
daspect([1 1 1]);
view(3); camlight; lighting gouraud;
title(['Watertight ', capitalize(tpmsType), ' (', num2str(domainSize), ' mm Cube)']);

% === Export STL ===
filename = [tpmsType, '.stl'];
TR = triangulation(F, V);
stlwrite(TR, filename);
disp(['STL file saved as ', filename]);

% === Utility: Capitalize first letter ===
function out = capitalize(str)
    out = lower(str);
    out(1) = upper(out(1));
end
