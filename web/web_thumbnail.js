async function generateVideoThumbnail(videoFile) {
  return new Promise((resolve, reject) => {
    try {
      const video = document.createElement('video');
      video.src = URL.createObjectURL(videoFile);
      video.crossOrigin = 'anonymous';
      video.muted = true;
      video.playsInline = true;

      const canvas = document.createElement('canvas');
      const context = canvas.getContext('2d');

      video.addEventListener('loadeddata', () => {
        try {
          // Set a frame at 1 second (adjust if video is shorter)
          video.currentTime = Math.min(1, video.duration / 2);
        } catch (e) {
          reject('Video seek error: ' + e);
        }
      });

      video.addEventListener('seeked', () => {
        try {
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;
          context.drawImage(video, 0, 0, video.videoWidth, video.videoHeight);
          canvas.toBlob((blob) => {
            if (blob) resolve(blob);
            else reject('Thumbnail generation failed: no blob created');
          }, 'image/jpeg');
        } catch (e) {
          reject('Draw error: ' + e);
        }
      });

      video.addEventListener('error', (e) => {
        reject('Video load error: ' + e.message);
      });
    } catch (err) {
      reject('General error: ' + err);
    }
  });
}
