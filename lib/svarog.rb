require "svarog/version"

module Svarog
  class MethodNotImplemented < StandardError; end
  class WrongDataPassed < StandardError; end
  class NonCallablePassedToRun < StandardError; end
  class CallMethodNotImplemented < StandardError; end

  Result = Struct.new(:success, :value) do
    def success?
      success
    end

    def failure?
      !success
    end
  end

  module Base
    def call(input = nil)
      input ||= {}
      @_passed_input = Result.new(true, input)
      begin
        super
      rescue NoMethodError
        raise CallMethodNotImplemented, "You have to implement `call` method in your class before using it"
      end
      enforce_data_format
      @_passed_input
    end

    private

    def run(callable)
      return unless @_passed_input.success?

      if callable.instance_of? Symbol
        raise MethodNotImplemented, "You didn't implement #{callable} method. Implement it before calling this class" unless respond_to?(callable, true)
        callable = method(callable)
      end

      raise NonCallablePassedToRun, "You can pass only symbol with method name of instance of callable class to run method" unless callable.respond_to?(:call)

      @_passed_input = callable.call(@_passed_input.value)
    end

    def success(value)
      Result.new(true, value)
    end

    def failure(value)
      Result.new(false, value)
    end

    def enforce_data_format
      raise WrongDataPassed, "You didn't use `success` or `failure` method to return value from method." unless @_passed_input.instance_of? Result
    end
  end
end
