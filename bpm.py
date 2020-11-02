import librosa
import numpy as np
np.set_printoptions(suppress=True)
y ,sr = librosa.load('./src/media/bgm.wav')
#onset_env = librosa.onset.onset_strength(y, sr=sr, hop_length=512, aggregate=np.median)
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
beat_times = librosa.frames_to_time(beats, sr=sr)
beat_times *= 10
beat_times = np.ceil(beat_times)
beat_times = beat_times.astype('int32')
beat_times_1 = beat_times.copy()
beat_times_1 = np.delete(beat_times_1,-1)
beat_times_1 = np.insert(beat_times_1,0,0)
beat_times -= beat_times_1
print(beat_times)
beat_times = list(beat_times)
beat_times = [str(_) for _ in beat_times]
beat_times = ", ".join(beat_times)
print(beat_times)