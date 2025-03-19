# frozen_string_literal: true

RSpec.describe RubyGit::CommandLine::Result do
  let(:result) { described_class.new(process_executer_result) }
  let(:process_executer_result) { ProcessExecuter.run(*command, **options) }
  let(:command) { ruby_command <<~RUBY }
    STDOUT.puts 'stdout message'
    STDERR.puts 'stderr message'
  RUBY
  let(:options) { { out: StringIO.new, err: StringIO.new } }

  describe '#stdout' do
    it 'should return the stdout' do
      expect(result.stdout.with_linux_eol).to eq("stdout message\n")
    end

    context 'when #process_stdout has been called' do
      it 'should return the value returned from #process_stdout' do
        result.process_stdout { |s, _r| s.upcase! }
        expect(result.stdout.with_linux_eol).to eq("STDOUT MESSAGE\n")
      end
    end

    context 'when #process_stdout has been called multiple times' do
      it 'should return the value returned from the last #process_stdout' do
        result.process_stdout { |s, _r| s.chomp!.upcase! }
        result.process_stdout { |s, _r| s.reverse! }
        expect(result.stdout.with_linux_eol).to eq('EGASSEM TUODTS')
      end
    end
  end

  describe '#process_stdout' do
    it 'should return self' do
      expect(result.process_stdout { |s, _r| s.upcase! }).to eq(result)
    end

    it 'should yield to the given block once' do
      expect { |b| result.process_stdout(&b) }.to yield_control.once
    end

    it 'should yield to the given block with the stdout and self' do
      expect { |b| result.process_stdout(&b) }.to yield_with_args("stdout message#{eol}", result)
    end

    context 'when called multiple times' do
      it 'should yield most recent value returned from #process_stdout' do
        result.process_stdout { |s, _r| s.upcase! }
        expect { |b| result.process_stdout(&b) }.to yield_with_args("STDOUT MESSAGE#{eol}", result)
      end
    end
  end

  describe '#unprocessed_stdout' do
    context 'when #process_stdout HAS NOT been called' do
      it 'should return stdout' do
        expect(result.unprocessed_stdout).to eq("stdout message#{eol}")
      end
    end

    context 'when #process_stdout HAS been called' do
      it 'should return the original stdout' do
        result.process_stdout { |s, _r| s.upcase! }
        expect(result.unprocessed_stdout).to eq("stdout message#{eol}")
      end
    end
  end

  describe '#stderr' do
    it 'should return the stderr' do
      expect(result.stderr.with_linux_eol).to eq("stderr message\n")
    end

    context 'when #process_stderr has been called' do
      it 'should return the value returned from #process_stderr' do
        result.process_stderr { |s, _r| s.upcase! }
        expect(result.stderr.with_linux_eol).to eq("STDERR MESSAGE\n")
      end
    end

    context 'when #process_stderr has been called multiple times' do
      it 'should return the value returned from the last #process_stderr' do
        result.process_stderr { |s, _r| s.chomp!.upcase! }
        result.process_stderr { |s, _r| s.reverse! }
        expect(result.stderr.with_linux_eol).to eq('EGASSEM RREDTS')
      end
    end
  end

  describe '#process_stderr' do
    it 'should return self' do
      expect(result.process_stderr { |s, _r| s.upcase! }).to eq(result)
    end

    it 'should yield to the given block once' do
      expect { |b| result.process_stderr(&b) }.to yield_control.once
    end

    it 'should yield to the given block with the stderr and self' do
      expect { |b| result.process_stderr(&b) }.to yield_with_args("stderr message#{eol}", result)
    end

    context 'when called multiple times' do
      context 'on the last time it is called' do
        it 'should yield most recent value returned from #process_stderr' do
          result.process_stderr { |s, _r| s.upcase! }
          expect { |b| result.process_stderr(&b) }.to yield_with_args("STDERR MESSAGE#{eol}", result)
        end
      end
    end
  end

  describe '#unprocessed_stderr' do
    context 'when #process_stderr HAS NOT been called' do
      it 'should return stderr' do
        expect(result.unprocessed_stderr.with_linux_eol).to eq("stderr message\n")
      end
    end

    context 'when #process_stderr HAS been called' do
      it 'should return the original stderr' do
        result.process_stderr { |s, _r| s.upcase! }
        expect(result.unprocessed_stderr.with_linux_eol).to eq("stderr message\n")
      end
    end
  end
end
