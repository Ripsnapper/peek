/*
Peek Copyright (c) 2015-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording {

  public class WfRecorder : CliScreenRecorder {
    ~WfRecorder () {
      cancel ();
    }

    protected override void start_recording (RecordingArea area) throws RecordingError {
      try {
        var args = new Array<string> ();
        args.append_val ("wf-recorder");
        // args.append_val ("--log");
        args.append_val ("-g");
        args.append_val (area.left.to_string () + "," + area.top.to_string () + " " + area.width.to_string () + "x" + area.height.to_string ());

        /*
           Generate temp file for unique name and delete it, because wf-recorder
           asks for confirmation before overwriting existing files
        */
        string extension = Utils.get_file_extension_for_format(config.output_format);
        temp_file = Utils.create_temp_file (extension);
        FileUtils.unlink(temp_file);

        args.append_val ("-f");
        args.append_val (temp_file);

        spawn_record_command (args.data);
      } catch (FileError e) {
        throw new RecordingError.INITIALIZING_RECORDING_FAILED (e.message);
      }
    }

    public static bool is_available () throws PeekError {
      return Utils.check_for_executable ("wf-recorder");
    }

    protected override void stop_recording () {
      if (subprocess != null && input != null) {
        try {
          subprocess.send_signal(2); // SIGINT
        } catch (Error e) {
          stderr.printf ("Error: %s\n", e.message);
          recording_aborted (new RecordingError.RECORDING_ABORTED (e.message));
        }
      }
    }
  }

}
