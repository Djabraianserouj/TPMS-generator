clc; clear; close all;

% === Parameters ===
domainSize = 40;       % Size of cube in mm
gridSize = 100;        % Grid resolution (higher = better quality)
scaleFactor = 1;       % Number of gyroid cells in the domain
thickness = 0.5;       % Offset level from zero (surface thickness)

% === Coordinate Grid ===
[x, y, z] = meshgrid( ...
    linspace(0, domainSize, gridSize), ...
    linspace(0, domainSize, gridSize), ...
    linspace(0, domainSize, gridSize));

% === Gyroid Field Calculation ===
scaledX = x * (2*pi*scaleFactor / domainSize);
scaledY = y * (2*pi*scaleFactor / domainSize);
scaledZ = z * (2*pi*scaleFactor / domainSize);

gyroid = sin(scaledX).*cos(scaledY) + ...
         sin(scaledY).*cos(scaledZ) + ...
         sin(scaledZ).*cos(scaledX);

% === Make Geometry Solid (use thickness offset) ===
obj = (gyroid - thickness) .* (gyroid + thickness);  % Enclosed "shell"

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
view(3);
camlight; lighting gouraud;
title('Watertight Gyroid (40 mm Cube)');

% === Export STL ===
filename = 'gyroid.stl';
TR = triangulation(F, V);  % Create triangulation object
stlwrite(TR, filename);    % Export STL
disp(['STL file saved as ', filename]);
