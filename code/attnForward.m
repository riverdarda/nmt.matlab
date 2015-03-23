function [attnHidVecs, attn_h_concat, alignWeights] = attnForward(h_t, model, params, srcHidVecs, curMask)
%%%
%
% Compute context vectors for attention-based models.
%
% Thang Luong @ 2015, <lmthang@stanford.edu>
%
%%%
  if params.assert
    assert(sum(sum(abs(h_t(:, curMask.maskedIds))))==0);
  end
  
  % s_t = W_a * h_t
  % align weights a_t = softmax(s_t): numAttnPositions*curBatchSize
  alignWeights = softmax(model.W_a*h_t);
  
  % alignWeights: numAttnPositions*curBatchSize
  % mask: 1 * curBatchSize
  % -> alignWeights: 1 * curBatchSize * numAttnPositions
  alignWeights = permute(bsxfun(@times, alignWeights, curMask.mask), [3, 2, 1]);
  
  % srcHidVecs: lstmSize * curBatchSize * numAttnPositions
  % alignWeights: 1 * curBatchSize * numAttnPositions
  % attention vectors: attn_t = H_src* a_t (weighted average of src vectors)
  % sum over numAttnPositions
  attnVecs = squeeze(sum(bsxfun(@times, srcHidVecs, alignWeights), 3)); 
  
  % attention hidden vectors: attnHid = f(W_ah*[attn_t; tgt_h_t])
  attn_h_concat = [attnVecs; h_t];
  attnHidVecs = params.nonlinear_f(model.W_ah*attn_h_concat);
end