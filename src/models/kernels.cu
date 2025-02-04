#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <stdint.h>

namespace Generators {
namespace cuda {

__global__ void Gpt_UpdatePositionIds(int32_t* positions, int batch_beam_size, int current_length) {
  for (int i = 0; i < batch_beam_size; i++)
    positions[i] = current_length - 1;
}

void LaunchGpt_UpdatePositionIds(int32_t* positions, int batch_beam_size, int current_length, cudaStream_t stream) {
  Gpt_UpdatePositionIds<<<1, 1, 0, stream>>>(positions, batch_beam_size, current_length);
}

__global__ void Gpt_UpdateMask(int32_t* mask_data, const int32_t* old_mask_data, int batch_beam_size, int current_length) {
  for (int i = 0; i < batch_beam_size; i++) {
    for (int j = 0; j < current_length - 1; j++) {
      mask_data[i * current_length + j] = old_mask_data[i * (current_length - 1) + j];
    }
    mask_data[i * current_length + current_length - 1] = 1;
  }
}

void LaunchGpt_UpdateMask(int32_t* mask_data, const int32_t* old_mask_data, int batch_beam_size, int current_length, cudaStream_t stream) {
  Gpt_UpdateMask<<<1, 1, 0, stream>>>(mask_data, old_mask_data, batch_beam_size, current_length);
}

__global__ void Gpt_UpdatePositionIds(int64_t* positions, int batch_beam_size, int current_length) {
  for (int i = 0; i < batch_beam_size; i++) {
    positions[i] = current_length - 1;
  }
}

void LaunchGpt_UpdatePositionIds(int64_t* positions, int batch_beam_size, int current_length, cudaStream_t stream) {
  Gpt_UpdatePositionIds<<<1, 1, 0, stream>>>(positions, batch_beam_size, current_length);
}

__global__ void Gpt_UpdateMask(int64_t* mask_data, const int64_t* old_mask_data, int batch_beam_size, int current_length) {
  for (int i = 0; i < batch_beam_size; i++) {
    for (int j = 0; j < current_length - 1; j++) {
      mask_data[i * current_length + j] = old_mask_data[i * (current_length - 1) + j];
    }
    mask_data[i * current_length + current_length - 1] = 1;
  }
}

void LaunchGpt_UpdateMask(int64_t* mask_data, const int64_t* old_mask_data, int batch_beam_size, int current_length, cudaStream_t stream) {
  Gpt_UpdateMask<<<1, 1, 0, stream>>>(mask_data, old_mask_data, batch_beam_size, current_length);
}

__global__ void ConvertFp16ToFp32(const half* src, float* dst, int count) {
  int idx = threadIdx.x + blockIdx.x * blockDim.x;
  if (idx < count) {
    dst[idx] = __half2float(src[idx]);
  }
}

void LaunchFp16ToFp32(const uint16_t* fp16, float* fp32, int count, cudaStream_t stream) {
  int block_size = 256;
  int num_blocks = (count + block_size - 1) / block_size;
  ConvertFp16ToFp32<<<num_blocks, block_size, 0, stream>>>(reinterpret_cast<const half*>(fp16), fp32, count);
}

__global__ void ConvertInt32ToInt64(const int32_t* src, int64_t* dst, int count) {
  int idx = threadIdx.x + blockIdx.x * blockDim.x;
  if (idx < count) {
    dst[idx] = src[idx];
  }
}

void LaunchInt32ToInt64(const int32_t* src, int64_t* dst, int count, cudaStream_t stream) {
  int block_size = 256;
  int num_blocks = (count + block_size - 1) / block_size;
  ConvertInt32ToInt64<<<num_blocks, block_size, 0, stream>>>(src, dst, count);
}

}  // namespace cuda
}  // namespace Generators
