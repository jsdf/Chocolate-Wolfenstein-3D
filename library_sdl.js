// additions and overrides to emscripten's builtin SDL library

LibrarySDL = {
  Mix_GroupAvailable: function() {},
  Mix_GroupChannels: function() {},
  Mix_GroupOldest: function() {},
  Mix_HookMusic: function() {},
  SDL_EventState: function() {},
  SDL_WaitEvent: function() {
    return 0;
  },
  // SDL_Delay: function() {

  //   // SDL_Delay
  // }
};

mergeInto(LibraryManager.library, LibrarySDL);
