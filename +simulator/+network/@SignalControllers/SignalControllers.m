classdef SignalControllers < utils.class.Container
    properties
        Config;
    end

    methods
        function obj = SignalControllers(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                obj.Config = UpperClass.Config;
                obj.set('Network', UpperClass);

                obj.create('Vissim');
                obj.create('Elements');

            elseif isa(UpperClass, 'simulator.network.Intersection')
                obj.Config = UpperClass.Config;
                obj.set('Intersection', UpperClass);

            else
                error('UpperClass must be a simulator.Network or simulator.network.Intersection class.');
            end
        end 
    end
end