module Listen
  module Adapter
    # Adapter implementation for Mac OS X `FSEvents`.
    #
    class Darwin < Base
      OS_REGEXP = /darwin(1.+)?$/i

      # The default delay between checking for changes.
      DEFAULTS = { latency: 0.1 }

      private

      def _configure(dir, &callback)
        require 'rb-fsevent'
        @worker ||= FSEvent.new
        opts = { latency: options.latency }
        @worker.watch(dir.to_s, opts, &callback)
      end

      def _run
        @worker.run
      end

      def _process_event(dir, event)
        event.each do |path|
          new_path = Pathname.new(path.sub(/\/$/, ''))
          #_log :debug, "fsevent: #{new_path}"
          # TODO: does this preserve symlinks?
          rel_path = new_path.relative_path_from(dir).to_s
          _queue_change(:dir, dir, rel_path, recursive: true)
        end
      end
    end
  end
end
