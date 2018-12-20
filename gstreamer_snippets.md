 - changing the src in a pipeline:

```
void VideoReceiver::updateAudioPort()
{
    bool changeStatus;
    uint32_t port = _videoSettings->audioUdpPort()->rawValue().toUInt();

    qCDebug(VideoReceiverLog) << "Trying to change audio udpsrc port to " << port;
    if (_audioPipeline) {

        // Stop Pipeline to change udpsrc
        qCDebug(VideoReceiverLog) << "Pausing audio pipeline...";
        changeStatus = gst_element_set_state(_audioPipeline, GST_STATE_READY);
        if (changeStatus == GST_STATE_CHANGE_SUCCESS) {
            qCDebug(VideoReceiverLog) << "Audio pipeline paused.";
        } else {
            qCWarning(VideoReceiverLog) << "Unable to pause pipeline, gst_element_set_state returned" << changeStatus;
            return;
        }

        // get udpsrc and unlink from capsfilter
        GstElement* udpsrc = gst_bin_get_by_name(GST_BIN(_audioPipeline), "udpsrc0");
        GstElement* caps = gst_bin_get_by_name(GST_BIN(_audioPipeline), "capsfilter0");
        gst_bin_remove(GST_BIN(_audioPipeline),udpsrc);

        // set udpsrc state to NULL to release network assets, unreference it to free memory
        qCDebug(VideoReceiverLog) << "Stopping old audio udpsrc socket...";
        changeStatus = gst_element_set_state(udpsrc, GST_STATE_NULL);
        if (changeStatus == GST_STATE_CHANGE_SUCCESS) {
            qCDebug(VideoReceiverLog) << "udpsrc stopped.";
        } else {
            qCWarning(VideoReceiverLog) << "Unable to stop udpsrc, gst_element_set_state returned" << changeStatus;
            return;
        }

        gst_object_unref (udpsrc);
        qCDebug(VideoReceiverLog) << udpsrc;

        // create new udpsrc, set new port, link to capsfilter, and synchronize with pipeline
        GstElement* newUdpSrc = gst_element_factory_make("udpsrc", "udpsrc0");
        g_object_set(newUdpSrc, "port", port, NULL);
        gst_bin_add(GST_BIN(_audioPipeline), newUdpSrc);
        gst_element_link(newUdpSrc, caps);
        gst_element_sync_state_with_parent(newUdpSrc);

        // restart pipeline with new udpsrc
        qCDebug(VideoReceiverLog) << "Playing audio pipeline...";
        changeStatus = gst_element_set_state(_audioPipeline, GST_STATE_PLAYING);
        if (changeStatus == GST_STATE_CHANGE_SUCCESS) {
            qCDebug(VideoReceiverLog) << "Audio pipeline playing.";
        } else {
            qCWarning(VideoReceiverLog) << "Unable to play pipeline, gst_element_set_state returned" << changeStatus;
            return;
        }
    }
}
```
