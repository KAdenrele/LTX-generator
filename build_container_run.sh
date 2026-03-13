docker build -t ltx_2_3_auto . && docker run \
                                            --gpus "device=1" \
                                            --shm-size=8g \
                                            --env-file .env \
                                            -v /mnt/data/test_dataset/models/LTX2_3:/workspace/LTX-2/LTX-Models \
                                            -v /mnt/data/test_dataset/models/Gemma:/workspace/LTX-2/Gemma-Models \
                                            -v /mnt/data3/video_clustering/videos/LTX2_3:/workspace/LTX-2/outputs \
                                            ltx_2_3_auto