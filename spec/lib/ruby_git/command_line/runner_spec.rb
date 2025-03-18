# frozen_string_literal: true

RSpec.describe RubyGit::CommandLine::Runner do
  let(:runner) { described_class.new(env, binary_path, global_options, logger) }

  let(:env) do
    {
      'MYVAR1' => 'myvar1_value',
      'MYVAR2' => 'myvar2_value'
    }
  end
  let(:binary_path) { 'bin/command_line_test' }
  let(:global_options) { {} }
  let(:logger) { Logger.new(nil) }

  describe '#initialize' do
    subject { runner }

    let(:expected_attributes) do
      {
        env: env,
        binary_path: binary_path,
        global_options: global_options,
        logger: logger
      }
    end

    it 'should have the expected attributes' do
      expect(subject).to have_attributes(expected_attributes)
    end
  end

  describe '#call' do
    it 'should assemble the command line correctly' do
      env = {
        'MYVAR1' => 'myvar1_value',
        'MYVAR2' => 'myvar2_value'
      }
      binary_path = 'bin/command_line_test'
      global_options = ['--env-var', 'MYVAR1']
      args = [
        '--stdout', 'stdout output',
        '--stderr', 'stderr output'
      ]
      logger = Logger.new(nil)

      expected_command = [env, binary_path, *global_options, *args]
      expected_options = { raise_git_errors: false, logger: Logger }

      runner = described_class.new(env, binary_path, global_options, logger)

      expect(ProcessExecuter).to(
        receive(:run_with_options).with(
          expected_command, an_object_having_attributes(**expected_options)
        ).and_call_original
      )

      runner.call(
        *args, chomp: true, raise_git_errors: false, out: StringIO.new, err: StringIO.new, logger:
      )
    end

    let(:result) { runner.call(*command_line_test_args, **options) }
    let(:env) { {} }
    let(:binary_path) { 'bin/command_line_test' }
    let(:global_options) { [] }
    let(:options) { { raise_git_errors:, timeout_after:, chomp: } }
    let(:raise_git_errors) { true }
    let(:timeout_after) { nil }
    let(:chomp) { false }

    subject { result }

    context 'with a successful command' do
      let(:command_line_test_args) { %w[--exitstatus 0] }

      let(:expected_result_attributes) do
        {
          success?: true,
          exitstatus: 0,
          signaled?: false,
          timed_out?: false,
          termsig: nil
        }
      end

      context 'when raise_git_errors is true' do
        let(:raise_git_errors) { true }

        it { is_expected.to have_attributes(expected_result_attributes) }
      end

      context 'when raise_git_errors is false' do
        let(:raise_git_errors) { false }

        it { is_expected.to have_attributes(expected_result_attributes) }
      end
    end

    context 'with a failed command' do
      let(:command_line_test_args) { %w[--exitstatus 1] }

      let(:expected_result_attributes) do
        {
          success?: false,
          exitstatus: 1,
          signaled?: false,
          timed_out?: false,
          termsig: nil
        }
      end

      context 'when raise_git_errors is true' do
        let(:raise_git_errors) { true }

        it 'should raise a RubyGit::FailedError' do
          expect { subject }.to raise_error(RubyGit::FailedError) do |e|
            expect(e.result).to have_attributes(expected_result_attributes)
          end
        end
      end

      context 'when raise_git_errors is false' do
        let(:raise_git_errors) { false }

        it 'should return a result indicating the failure' do
          expect(subject).to have_attributes(expected_result_attributes)
        end
      end
    end

    context 'with a signaled command' do
      let(:command_line_test_args) { %w[--signal 9] }

      let(:expected_result_attributes) do
        {
          success?: nil,
          exitstatus: nil,
          signaled?: true,
          timed_out?: false,
          termsig: 9
        }
      end

      context 'when raise_git_errors is true' do
        let(:raise_git_errors) { true }

        it 'should raise a RubyGit::SignaledError' do
          expect { subject }.to raise_error(RubyGit::SignaledError) do |e|
            expect(e.result).to have_attributes(expected_result_attributes)
          end
        end
      end

      context 'when raise_git_errors is false' do
        let(:raise_git_errors) { false }

        it 'should return a result indicating the signal' do
          expect(subject).to have_attributes(expected_result_attributes)
        end
      end
    end

    context 'with a timeout error' do
      let(:command_line_test_args) { %w[--duration 0.1] }

      let(:expected_result_attributes) do
        {
          success?: nil,
          exitstatus: nil,
          signaled?: true,
          timed_out?: true,
          termsig: 9
        }
      end

      context 'when raise_git_errors is true' do
        let(:raise_git_errors) { true }
        let(:timeout_after) { 0.05 }

        it 'should raise a RubyGit::SignaledError' do
          expect { subject }.to raise_error(RubyGit::SignaledError) do |e|
            expect(e.result).to have_attributes(expected_result_attributes)
          end
        end
      end

      context 'when raise_git_errors is false' do
        let(:raise_git_errors) { false }
        let(:timeout_after) { 0.05 }

        it 'should return a result indicating the signal' do
          expect(subject).to have_attributes(expected_result_attributes)
        end
      end
    end

    describe 'chomping output' do
      let(:command_line_test_args) { %w[--stdout stdout_output --stderr stderr_output] }
      let(:options) { { out: StringIO.new, err: StringIO.new, chomp: chomp } }

      context 'when chomping is enabled' do
        let(:chomp) { true }

        it 'should chomp stdout' do
          expect(subject.stdout).to eq('stdout_output')
        end

        it 'should chomp stderr' do
          expect(subject.stderr).to eq('stderr_output')
        end
      end

      context 'when chomping is disabled' do
        let(:chomp) { false }

        it 'should not chomp stdout' do
          expect(subject.stdout).to eq("stdout_output\n")
        end

        it 'should not chomp stderr' do
          expect(subject.stderr).to eq("stderr_output\n")
        end
      end
    end

    describe 'encoding normalization of output' do
      let(:options) { { out: StringIO.new, err: StringIO.new, normalize_encoding: } }

      let(:expected_non_normalized_output) do
        output =
          "\xCB\xEF\xF1\xE5\xEC \xE9\xF0\xF3\xE8\xEC \xE4\xEF\xEB\xEF\xF1 \xF3\xE9\xF4#{eol}" \
          "\xC7\xE9\xF3 \xE5\xEE \xF4\xEF\xF4\xE1 \xF3\xE8\xE1v\xE9\xF4\xE1\xF4\xE5#{eol}" \
          "\xCD\xEF \xE8\xF1\xE2\xE1\xED\xE9\xF4\xE1\xF3#{eol}" \
          "\xD6\xE5\xE8\xE3\xE9\xE1\xF4 \xE8\xF1\xE2\xE1\xED\xE9\xF4\xE1\xF3 " \
          "\xF1\xE5\xF0\xF1\xE9\xEC\xE9q\xE8\xE5#{eol}"
        output.force_encoding('ASCII-8BIT')
      end

      let(:expected_normalized_output) { <<~OUTPUT }
        Λορεμ ιπσθμ δολορ σιτ
        Ηισ εξ τοτα σθαvιτατε
        Νο θρβανιτασ
        Φεθγιατ θρβανιτασ ρεπριμιqθε
      OUTPUT

      # The test script adds a carriage return for each line on windows
      let(:eol) { RUBY_PLATFORM =~ /mswin|mingw/ ? "\r\n" : "\n" }

      context 'when normalization is enabled' do
        let(:normalize_encoding) { true }

        context 'with output containing mixed encoding' do
          let(:command_line_test_args) { %w[--stdout-file spec/fixtures/mixed_encoding.txt] }
          it 'should normalize the encoding' do
            expect(subject.stdout).to eq(expected_normalized_output)
          end
        end
      end

      context 'when normalization is disabled' do
        let(:normalize_encoding) { false }

        context 'with output containing mixed encoding' do
          let(:command_line_test_args) { %w[--stdout-file spec/fixtures/mixed_encoding.txt] }

          it 'should NOT normalize the encoding' do
            expect(subject.stdout).to eq(expected_non_normalized_output)
          end
        end
      end
    end

    context 'when the command has a pipe IO error' do
      let(:command_line_test_args) { %w[--stdout stdout_output] }

      let(:out) do
        Class.new do
          def write(*_args)
            raise IOError, 'error writing to file'
          end
        end.new
      end

      let(:options) { { raise_git_errors:, out: } }

      context 'when :raise_git_errors is true' do
        let(:raise_git_errors) { true }

        it 'should raise a RubyGit::ProcessIOError' do
          expect { subject }.to raise_error(RubyGit::ProcessIOError)
        end
      end

      context 'when :raise_git_errors is false' do
        let(:raise_git_errors) { false }

        it 'should raise a RubyGit::ProcessIOError (even if told not to raise errors)' do
          expect { subject }.to raise_error(RubyGit::ProcessIOError)
        end
      end
    end
  end
end
