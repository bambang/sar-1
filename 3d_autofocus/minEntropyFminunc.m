% The following is a MATLAB implementation of the standard gradient descent
% minimization of the image entropy cost function.
%
% B is a 4D array of b_k values
% L is the number of iterations
function [ focusedImage, minEntropy ] = minEntropyFminunc( B, L )
  MAX_ITER = 100;
  K = size(B, 4);
  l = 2;
  minIdx = 1;
  minEntropy = 100;

  % Holds array of potentially minimizing phase offsets - 100 is an arbitrary
  % maximum number of iterations
  %
  % Guess zero initially
  phi_offsets = zeros(MAX_ITER, K);

  % Step size parameter for gradient descent
  s = 10;

  while (1) % phi_offsets(1) = 0
    phi_offsets(l, :) = phi_offsets(l - 1, :) - s * gradH(phi_offsets(l - 1, :), B);
    focusedImage = image(phi_offsets(l, :), B);
    tempEntropy = H(focusedImage);
    
    fprintf('tempEntropy = %d, minEntropy = %d\n', tempEntropy, minEntropy);
    if (tempEntropy < minEntropy && minEntropy - tempEntropy > 0.5) % break if decreases in entropy are small
        minIdx = l;
        minEntropy = tempEntropy;
    else
        break;
    end
    s = s / 1;
    l = l + 1;
  end
end

function [grad] = gradH(phi_offsets, B)
    K = numel(phi_offsets);
    grad = zeros(1, K);

    delta = 1; % arbitrary constant for finite difference

    % k x k identity matrix in MATLAB
    ident = eye(K);

    fprintf('In gradH, about to compute Z\n');
    Z = image(phi_offsets, B);
    fprintf('Computed Z\n');
    H_not = H(Z);
    fprintf('Computed H_not\n');

    parfor k = 1:K
      % fprintf('Computing Z for k=%d\n', k);
      Z = image(phi_offsets + transpose(ident(:, k) * delta), B);
      grad(k) = (H(Z) - H_not) / delta;
    end
end

function [entropy] = H(Z)
  Z_mag = Z .* conj(Z);         
  Ez = findEz(Z);                   

  Z_intensity = Z_mag / Ez;
  entropy = - sum(sum(sum(Z_intensity .* log(Z_intensity))));
end

function [out] = image(phi_offsets, B) % defines z_vec(phi)
  X = size(B, 1); Y = size(B, 2); Z = size(B, 3);
  out = zeros(X, Y, Z);
  K = numel(phi_offsets);

  for x = 1:X
      for y = 1:Y
          for z = 1:Z
              out(x,y,z) = out(x,y,z) + sum(reshape(B(x,y,z,:), 1, K) .* exp(-1j .* phi_offsets));
          end
      end
  end
end

function [Ez] = findEz(Z)
  Ez = sum(sum(sum(Z .* conj(Z))));
end
