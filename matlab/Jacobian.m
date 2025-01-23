function Fq = Jacobian(q)
% Fq = Jacobian(q)
% This function calculates the Jacobian matrix for the constraint equations.
% It includes detailed checks and logs for debugging.
% 
% Input:
%   q - The vector of absolute coordinates, including positions (x, y) and angles (fi).
% Output:
%   Fq - The constraint Jacobian matrix.

    % Step 1: Load mechanism data
    data;

    % Step 2: Define a constant matrix
    Om = [0 -1; 1 0];

    % Step 3: Extract positions and angles from q
    r1 = q(1:2); fi1 = q(3); 
    r2 = q(4:5); fi2 = q(6);
    r3 = q(7:8); fi3 = q(9);
    r4 = q(10:11); fi4 = q(12);
    r5 = q(13:14); fi5 = q(15);
    r6 = q(16:17); fi6 = q(18);
    r7 = q(19:20); fi7 = q(21);
    r8 = q(22:23); fi8 = q(24);

    % Step 4: Compute rotation matrices
    Rot1 = Rot(fi1); Rot2 = Rot(fi2); Rot3 = Rot(fi3);
    Rot4 = Rot(fi4); Rot5 = Rot(fi5); Rot6 = Rot(fi6);
    Rot7 = Rot(fi7); Rot8 = Rot(fi8);

    % Step 5: Initialize the Jacobian matrix
    Fq = zeros(24, 24);

    % Debugging: Log initial Jacobian size

    % Step 6: Fill in Jacobian matrix for revolute joints
    try
        % Joint O-D (Frame 0, Frame 1)
        Fq(1:2, 1:2) = -eye(2);
        Fq(1:2, 3) = -Om * Rot1 * sB01;

        % Joint O-H (Frame 0, Frame 7)
        Fq(3:4, 19:20) = -eye(2);
        Fq(3:4, 21) = -Om * Rot7 * sB07;

        % Joint O-N (Frame 0, Frame 5)
        Fq(5:6, 13:14) = -eye(2);
        Fq(5:6, 15) = -Om * Rot5 * sB05;

        % Joint G-C (Frame 8, Frame 2)
        Fq(7:8, 22:23) = eye(2);
        Fq(7:8, 24) = Om * Rot8 * sA82;
        Fq(7:8, 4:5) = -eye(2);
        Fq(7:8, 6) = -Om * Rot2 * sB82;

        % Joint M-D (Frame 6, Frame 1)
        Fq(9:10, 16:17) = eye(2);
        Fq(9:10, 18) = Om * Rot6 * sA61;
        Fq(9:10, 1:2) = -eye(2);
        Fq(9:10, 3) = -Om * Rot1 * sB61;

        % Joint D-C (Frame 1, Frame 2)
        Fq(11:12, 1:2) = eye(2);
        Fq(11:12, 3) = Om * Rot1 * sA12;
        Fq(11:12, 4:5) = -eye(2);
        Fq(11:12, 6) = -Om * Rot2 * sB12;

        % Joint C-B (Frame 2, Frame 4)
        Fq(13:14, 4:5) = eye(2);
        Fq(13:14, 6) = Om * Rot2 * sA24;
        Fq(13:14, 10:11) = -eye(2);
        Fq(13:14, 12) = -Om * Rot4 * sB24;

        % Joint B-A (Frame 4, Frame 3)
        Fq(15:16, 10:11) = eye(2);
        Fq(15:16, 12) = Om * Rot4 * sA43;
        Fq(15:16, 7:8) = -eye(2);
        Fq(15:16, 9) = -Om * Rot3 * sB43;

        % Joint D-A (Frame 1, Frame 3)
        Fq(17:18, 1:2) = eye(2);
        Fq(17:18, 3) = Om * Rot1 * sA13;
        Fq(17:18, 7:8) = -eye(2);
        Fq(17:18, 9) = -Om * Rot3 * sB13;

    catch ME
        disp('Error while filling Jacobian for revolute joints:');
        disp(ME.message);
        rethrow(ME);
    end

    % Step 7: Fill in Jacobian matrix for translational joints
    try
        % Joint 5-6
        Fq(19, 15) = 1;
        Fq(19, 18) = -1;
        Fq(20, 13:14) = -(Rot6 * v56)';
        Fq(20, 15) = -(Rot6 * v56)' * Om * Rot5 * sA56;
        Fq(20, 16:17) = (Rot6 * v56)';
        Fq(20, 18) = -(Rot6 * v56)' * Om * (r6 - r5 - Rot5 * sA56);

        % Joint 7-8
        Fq(21, 21) = 1;
        Fq(21, 24) = -1;
        Fq(22, 19:20) = -(Rot8 * v78)';
        Fq(22, 21) = -(Rot8 * v78)' * Om * Rot7 * sA78;
        Fq(22, 22:23) = (Rot8 * v78)';
        Fq(22, 24) = -(Rot8 * v78)' * Om * (r8 - r7 - Rot7 * sA78);

    catch ME
        disp('Error while filling Jacobian for translational joints:');
        disp(ME.message);
        rethrow(ME);
    end

    % Step 8: Fill in Jacobian matrix for driving constraints
    try
        % Joint 5-6
        Fq(23, 13:14) = -(Rot6 * u56)';
        Fq(23, 15) = -(Rot6 * u56)' * Om * Rot5 * sA56;
        Fq(23, 16:17) = (Rot6 * u56)';
        Fq(23, 18) = -(Rot6 * u56)' * Om * (r6 - r5 - Rot5 * sA56);

        % Joint 7-8
        Fq(24, 19:20) = -(Rot8 * u78)';
        Fq(24, 21) = -(Rot8 * u78)' * Om * Rot7 * sA78;
        Fq(24, 22:23) = (Rot8 * u78)';
        Fq(24, 24) = -(Rot8 * u78)' * Om * (r8 - r7 - Rot7 * sA78);

    catch ME
        disp('Error while filling Jacobian for driving constraints:');
        disp(ME.message);
        rethrow(ME);
    end

   
end
