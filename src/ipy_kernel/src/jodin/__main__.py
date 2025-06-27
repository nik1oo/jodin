from .kernel import OdinKernel
if __name__ == '__main__':
    import ipykernel.kernelapp
    ipykernel.kernelapp.IPKernelApp.launch_instance(kernel_class=OdinKernel)