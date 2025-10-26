package dev.coderats.backend.users.api;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import dev.coderats.backend.users.api.dto.GroupSummaryDTO;
import dev.coderats.backend.users.api.dto.PrivateUserProfileDTO;
import dev.coderats.backend.users.api.dto.PublicUserProfileDTO;
import dev.coderats.backend.users.api.dto.PublicUserProfileWithGroupsDTO;
import dev.coderats.backend.users.api.dto.UserUpdateDTO;
import dev.coderats.backend.users.app.command.UpdateMeCommand;
import dev.coderats.backend.users.app.query.GroupSummaryView;
import dev.coderats.backend.users.app.query.PublicProfileView;
import dev.coderats.backend.users.app.query.PublicProfileWithGroupsView;
import dev.coderats.backend.users.domain.User;
import dev.coderats.backend.users.domain.UserId;

@Component
public class UserApiMapper {

    public UpdateMeCommand toUpdateMeCommand(UserUpdateDTO dto, UserId userId) {
        return new UpdateMeCommand(
            userId,
            dto.name(),
            dto.image(),
            dto.githubUser()
        );
    }

    public PrivateUserProfileDTO toPrivateProfileDTO(User user) {
        return new PrivateUserProfileDTO(
            user.id().asUuid(),
            user.name(),
            user.email(),
            user.image().orElse(null),
            user.githubUser().orElse(null)
        );
    }
    
    public PublicUserProfileWithGroupsDTO toPublicProfileWithGroupsDTO(PublicProfileWithGroupsView view) {
        
        PublicProfileView profileView = view.profile();
        
        PublicUserProfileDTO profileDTO = new PublicUserProfileDTO(
            UUID.fromString(profileView.id()),
            profileView.name(),
            profileView.image(),
            profileView.githubUser(),
            profileView.points()
        );
        
        List<GroupSummaryDTO> groupsDTO = view.commonGroups().stream()
            .map(this::toGroupSummaryDTO)
            .collect(Collectors.toList());
        
        return new PublicUserProfileWithGroupsDTO(profileDTO, groupsDTO);
    }
    
    private GroupSummaryDTO toGroupSummaryDTO(GroupSummaryView view) {
        return new GroupSummaryDTO(
            UUID.fromString(view.id()),
            view.name(),
            view.status(),
            view.image()
        );
    }
}