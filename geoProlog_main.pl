% =================================
% PROJECT: GeoProlog - Smart Urban Waste Collection & Vehicle Routing System
% COURSE:  COU4303 - Artificial Intelligence
% =====================




% --------------------------------------------
% 1. KNOWLEDGE BASE: Nodes & Road Connections
% --------------------------------

% Node Coordinates: loc(NodeName, X_Coordinate, Y_Coordinate)
location(depot,         0,  0).
location(zone_a_hub,   10, 15).
location(zone_b_hub,   25, 10).
location(bin_1,        12, 30).
location(bin_2,        28, 25).
location(bin_3,        35, 35).
location(landfill,     50, 40).

% Road Connections: edge(StartNode, EndNode, Distance_In_KM)
road(depot, zone_a_hub, 8).
road(depot, zone_b_hub, 12).
road(zone_a_hub, bin_1, 6).
road(zone_a_hub, bin_2, 10).
road(zone_b_hub, bin_2, 5).
road(zone_b_hub, bin_3, 9).
road(bin_1, bin_2, 7).
road(bin_2, landfill, 14).
road(bin_3, landfill, 8).
