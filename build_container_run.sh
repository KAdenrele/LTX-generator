docker build -t ltx_2_3_auto . && docker run --rm \
                                            --gpus "device=0" \
                                            --shm-size=8g \
                                            --env-file .env \
                                            -e HF_TOKEN=${HF_TOKEN} \
                                            -v /mnt/data/test_dataset/models/LTX2_3:/workspace/LTX-2/LTX-Models \
                                            -v /mnt/data/test_dataset/models/Gemma:/workspace/LTX-2/Gemma-Models \
                                            -v /mnt/data/test_dataset/raw/videos/LTX2_3:/workspace/LTX-2/outputs \
                                            ltx_2_3_auto