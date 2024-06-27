(function ($) {
  "use strict";

  $(document).ready(function () {
    //Declare auth
    var Uname = "super_user";
    var Pass = "triller";

    //Check if video exists
    if ($(".tpc-video-controls video").length > 0) {
      $(".tpc-video-controls video").each(function () {
        //Trigger video Play/Pause custom controls
        var video = $(this);
        video[0].addEventListener("click", function () {
          //Pause other videos
          document
            .querySelectorAll(".tpc-video-controls video")
            .forEach(function (vid) {
              //Check if not current video
              if (vid != video[0]) {
                vid.pause();
                $(vid).parent().addClass("tpc-paused");
              }

              //Remove default overlay if exists
              if (
                $(vid).siblings(".elementor-custom-embed-image-overlay")
                  .length > 0
              ) {
                $(vid)
                  .siblings(".elementor-custom-embed-image-overlay")
                  .remove();
              }
            });

          //Check if video paused
          if (video[0].paused) {
            video[0].play();
            video.parent().removeClass("tpc-paused");
          } else {
            video[0].pause();
            video.parent().addClass("tpc-paused");
          }
        });
      });
    }

    //Function to return Random String
    function tpc_makeID(length) {
      var result = "";
      var characters =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
      var charactersLength = characters.length;
      for (var i = 0; i < length; i++) {
        result += characters.charAt(
          Math.floor(Math.random() * charactersLength)
        );
      }
      return result;
    }

    //Function to update object in local storage
    function tpc_updateLocalStorageObj(key, value, mainKey) {
      var data = JSON.parse(localStorage.getItem(mainKey));
      data[key] = value;
      localStorage.setItem(mainKey, JSON.stringify(data));
    }

    //Generate New Voter for compaigns
    if (TRILLERPC_Data.Compaigns) {
      $.each(TRILLERPC_Data.Compaigns, function (Key, Value) {
        //Get compaign voter data
        var compaign_voter = localStorage.getItem(Key + "_voter");
        if (compaign_voter == "" || compaign_voter == null) {
          //Create new voter
          jQuery.ajax({
            type: "POST",
            url: Value.NewVoter,
            beforeSend: function (xhr) {
              xhr.setRequestHeader(
                "Authorization",
                "Basic " + btoa(Uname + ":" + Pass)
              );
            },
            complete: function () {
              //$_this.removeAttr( 'disabled' );
            },
            success: function (data, status, XMLHttpRequest) {
              if (data.data.voter_id) {
                //Set voter id and status
                var voter_data = {
                  voter_id: data.data.voter_id,
                  voter_status: false,
                };
                localStorage.setItem(
                  Key + "_voter",
                  JSON.stringify(voter_data)
                );

                //Show compaign's all vote buttons
                if (
                  $(
                    'div.tpc-coverstar-cat-list-wrap[data-compaignkey="' +
                      Key +
                      '"]'
                  ).length > 0
                ) {
                  $(
                    'div.tpc-coverstar-cat-list-wrap[data-compaignkey="' +
                      Key +
                      '"]'
                  ).each(function () {
                    $(this)
                      .find(".tpc-coverstar-vote:not(.voted)")
                      .removeClass("tpc-hidden");
                  });
                }
              }
            },
          });
        }
      });
    }

    //Loop for each compaigns
    if ($(".tpc-coverstar-cat-list-wrap").length > 0) {
      $(".tpc-coverstar-cat-list-wrap").each(function () {
        //Get required details
        var catlistwrap = $(this);
        var compaignKey = catlistwrap.attr("data-compaignkey");
        var compaignVoter = JSON.parse(
          localStorage.getItem(compaignKey + "_voter")
        );

        //Show vote button if still not voted
        if (compaignVoter && !compaignVoter.voter_status) {
          catlistwrap
            .find(".tpc-coverstar-vote:not(.voted)")
            .removeClass("tpc-hidden");
        }

        //Check voter status
        if (
          compaignVoter &&
          compaignVoter.voter_status &&
          compaignVoter.voter_id
        ) {
          //Get API URL
          var api_url = TRILLERPC_Data.Compaigns[compaignKey].Status.replace(
            "{voter_id}",
            compaignVoter.voter_id
          );

          //Status of compaignvoter
          jQuery.ajax({
            type: "GET",
            url: api_url,
            beforeSend: function (xhr) {
              xhr.setRequestHeader(
                "Authorization",
                "Basic " + btoa(Uname + ":" + Pass)
              );
            },
            complete: function () {
              //catlistwrap.removeAttr( 'disabled' );
            },
            success: function (data, status, XMLHttpRequest) {
              if (data.data.daily_vote) {
                if ($("#" + data.data.daily_vote.choice).length > 0) {
                  $("#" + data.data.daily_vote.choice)
                    .find(".tpc-coverstar-vote")
                    .removeClass("tpc-hidden")
                    .addClass("voted");
                  catlistwrap
                    .find(".tpc-coverstar-vote:not(.voted)")
                    .addClass("tpc-hidden");
                }
              }
            },
          });
        }
      });
    }

    //Get voter session id
    // OLD code for Backup
    /*var compaign_1_voter = localStorage.getItem('compaign_1_voter');
		if( compaign_1_voter == '' || compaign_1_voter == null ) {

			//Create new voter
			jQuery.ajax({
                type : 'POST',
                url  : TRILLERPC_Data.Api_C1_NewVoter,
                beforeSend: function(xhr) {
                	xhr.setRequestHeader ("Authorization", "Basic " + btoa(Uname + ":" + Pass));
                },
                complete: function(){
                    //$_this.removeAttr( 'disabled' );
                },
                success: function(data, status, XMLHttpRequest) {
                    console.log( 'data ' );
                    console.log( data );
                    console.log( 'datavoter_id ' );
                    console.log( data.data.voter_id );

                    if(data.data !== undefined) {
						//Set voter id and status
						var voter_data = { 'voter_id': data.data.voter_id, 'voter_status': false };
						localStorage.setItem('compaign_1_voter', JSON.stringify(voter_data) );
                    }
                }
            });
		}*/

    //Click on cover star vote button
    $(document).on("click", ".tpc-coverstar-vote", function (e) {
      e.preventDefault();
      var voteBtn = $(this);
      var choice = voteBtn.parents(".tpc-coverstar-list-wrap").attr("id");
      var compaignKey = voteBtn
        .parents(".tpc-coverstar-cat-list-wrap")
        .attr("data-compaignkey");
      var compaignVoter = JSON.parse(
        localStorage.getItem(compaignKey + "_voter")
      );

      //Check voter status
      if (!compaignVoter.voter_status && compaignVoter.voter_id) {
        //Get API URL
        var api_url = TRILLERPC_Data.Compaigns[compaignKey].Vote;

        jQuery.ajax({
          type: "POST",
          url: api_url,
          data: {
            voter_id: compaignVoter.voter_id,
            choice: choice,
          },
          beforeSend: function () {
            voteBtn.attr("disabled", "disabled");
          },
          complete: function () {
            voteBtn.removeAttr("disabled");
          },
          success: function (data, status, XMLHttpRequest) {
            if (data.data.voter_id) {
              voteBtn.removeClass("tpc-hidden").addClass("voted");
              voteBtn
                .parents(".tpc-coverstar-cat-list-wrap")
                .find(".tpc-coverstar-vote:not(.voted)")
                .addClass("tpc-hidden");

              //update voter status
              tpc_updateLocalStorageObj(
                "voter_status",
                true,
                compaignKey + "_voter"
              );

              //Display Vote Thanks popup
              $("#tpc-coverstar-vote-popup").addClass("show");
            }
          },
        });
      }
    });

    //Click on copy button
    $(document).on("click", ".tpc-coverstar-share-copy-btn", function () {
      $(this).siblings("textarea").select();
      document.execCommand("copy");
    });

    //Click on cover star video to open popup
    $(document).on("click", ".tpc-video img", function () {
      //Replace video and show popup
      var $_img = $(this);
      $("#tpc-coverstar-video-popup video.tpc-popup-video").attr(
        "src",
        $_img.attr("data-videourl")
      );
      $("#tpc-coverstar-video-popup video.tpc-popup-video").attr(
        "poster",
        $_img.attr("src")
      );
      $("#tpc-coverstar-video-popup video.tpc-popup-video")[0].play();
      $("#tpc-coverstar-video-popup").addClass("show");
    });

    //Click on video popup close
    $(document).on("click", ".tpc-popup-close", function () {
      var $_this = $(this);
      if (
        $_this.parents(".tpc-video-popup-wrap-inner").find("video").length > 0
      ) {
        $_this.parents(".tpc-video-popup-wrap-inner").find("video")[0].pause();
      }
      $_this.parents(".tpc-video-popup-wrap").removeClass("show");
    });

    //Click on video overlay to close
    $(document).on("click", ".tpc-video-popup-wrap.show", function (e) {
      if (e.target.classList.contains("tpc-video-wrapper")) {
        var $_this = $(this);
        if ($_this.find("video").length > 0) {
          $_this.find("video")[0].pause();
        }
        $_this.removeClass("show");
      }
    });
  });
})(jQuery);
