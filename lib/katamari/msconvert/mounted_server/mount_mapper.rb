
class Katamari
  class Msconvert
    module MountedServer

      class MountMapper
        attr_accessor :mount_dir
        attr_reader :mount_dir_pieces
        attr_accessor :tmp_subdir
        def initialize(mount_dir, tmp_subdir=MountedServer::DEFAULT_MOUNT_TMP_SUBDIR)
          @mount_dir = File.expand_path(mount_dir)
          @mount_dir_pieces = split_filename(@mount_dir)
          @tmp_subdir = tmp_subdir
        end

        # OS independent filename splitter "/path/to/file" =>
        # ['path','to','file']
        def split_filename(fn)
          fn.split(/[\/\\]/)
        end

        # OS independent basename getter
        def basename(fn)
          split_filename(fn).last
        end

        def under_mount?(filename)
          split_filename(File.expand_path(filename))[0,@mount_dir_pieces.size] == @mount_dir_pieces
        end

        # assumes the file is already under the mount
        # returns its path relative to the mount
        def relative_path(filename)
          pieces = split_filename(File.expand_path(filename))
          File.join(pieces[@mount_dir_pieces.size..-1])
        end

        # move the file under the mount.  If @tmp_subdir is defined, it will use that directory.
        # returns the expanded path of the file
        def cp_under_mount(filename)
          dest = File.join(@mount_dir, tmp_subdir || "", File.basename(filename))
          FileUtils.cp( filename, dest )
          dest
        end

        def full_path(relative_filename)
          File.join(@mount_dir, relative_filename)
        end
      end

    end # MountedServer
  end # Msconvert
end # Katamari

