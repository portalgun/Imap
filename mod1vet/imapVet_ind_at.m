classdef imapVet_ind_at < handle & imapVet_ind_plot
% part of imapVetInd
methods
    function obj=vet_at(obj,anch,bPlot,p)
        if exist('p','var') && isa(p,'pr')
            obj.p=p;
            obj.bp=1;
        else
            obj.bp=0;
        end

        while true
            % MAP ONLY
            [k,nk]=obj.xyz.get_k(anch);
            obj.mod_init();
            bBoth=all(obj.bVetInVec(k,:));

            %A
            if obj.bVetAt(k,k)
                obj.message('At',k,k);
                obj.vet_at_main(k,k);
            end
            if bBoth
                obj.update_CP_from_anch(k); % NOTE
            else
                obj.update_anch_from_map(k);
                obj.update_vet_from_map(k);
                break
            end

            if obj.returnFlag==1; break; end

            if ~bBoth & bPlot; obj.debug_plot('At',33,k); end

            % B
            if obj.bVetAt(k,nk)
                obj.message('At',k,nk);
                %obj.vet_at_main(k,nk);
                obj.update_vet_from_CP(k); % NOTE
            end
            if obj.returnFlag; break; end

            if bPlot; obj.debug_plot('At',33,k); end
            break
        end

    end
%%
    function obj=vet_at_main(obj,k,cp)
        % MAKES SENSE ONLY AGAINST VETIMAP
        if obj.bVetAgainst(cp)
            obj.gdMap{k}{cp}=obj.gdMap{k}{cp} & ~obj.tstMap{cp};
        elseif obj.bVetFor(cp)
            obj.gdMap{k}{cp}=obj.gdMap{k}{cp} &  obj.tstMap{cp};
        elseif obj.bVetEither(cp)
            obj.gdMap{k}{cp}=obj.gdMap{k}{cp} | obj.tstMap{cp};
        end

        if all(~obj.gdMap{k}{cp}(:)); obj.returnFlag=1; return; end
    end
end
end
