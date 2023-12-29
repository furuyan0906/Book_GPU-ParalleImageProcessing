#ifndef CUH__CUDA_UTIL__CUH
#define CUH__CUDA_UTIL__CUH

#include <memory>
#include <type_traits>
#include <cuda_runtime_api.h>
#include "cuda_error_check.cuh"

namespace cuda
{
    struct Deleter
    {
        void operator() (void* p) const
        {
            CHECK_CUDA_ERROR(::cudaFree(p));
        }
    };

    template<typename T>
    using shared_ptr = std::shared_ptr<T>;

    template<typename T>
    typename std::enable_if<std::is_array<T>::value, cuda::shared_ptr<T>>::type make_shared(std::size_t n)
    {
        using U = typename std::remove_extent<T>::type;

        U* p;
        CHECK_CUDA_ERROR(::cudaMalloc(reinterpret_cast<void**>(&p), sizeof(U) * n));
        return cuda::shared_ptr<T>(p, cuda::Deleter());
    }

    template<typename T>
    cuda::shared_ptr<T> make_shared()
    {
        T* p;
        CHECK_CUDA_ERROR(::cudaMalloc(reinterpret_cast<void**>(&p), sizeof(T)));
        return cuda::shared_ptr<T>(p, cuda::Deleter());
    }

    template<typename T>
    using unique_ptr = std::unique_ptr<T, Deleter>;

    template<typename T>
    typename std::enable_if<std::is_array<T>::value, cuda::unique_ptr<T>>::type make_unique(std::size_t n)
    {
        using U = typename std::remove_extent<T>::type;

        U* p;
        CHECK_CUDA_ERROR(::cudaMalloc(reinterpret_cast<void**>(&p), sizeof(U) * n));
        return cuda::unique_ptr<T>{p};
    }

    template<typename T>
    cuda::unique_ptr<T> make_unique()
    {
        T* p;
        CHECK_CUDA_ERROR(::cudaMalloc(reinterpret_cast<void**>(&p), sizeof(T)));
        return cuda::unique_ptr<T>{p};
    }
};

#endif  // CUH__CUDA_UTIL__CUH

